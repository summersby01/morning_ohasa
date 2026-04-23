import { cpSync, createWriteStream, existsSync, rmSync, renameSync } from 'node:fs';
import { mkdir } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';
import https from 'node:https';

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dirname, '..');
const sdkDir = join(projectRoot, '.flutter-sdk');
const tempDir = join(projectRoot, '.tmp');
const buildHomeDir = join(projectRoot, '.vercel-home');
const pubCacheDir = join(projectRoot, '.pub-cache');
const xdgConfigDir = join(buildHomeDir, '.config');

function moveDirectorySafe(sourcePath, destinationPath) {
  try {
    renameSync(sourcePath, destinationPath);
    return;
  } catch (error) {
    if (error?.code !== 'EXDEV') {
      throw error;
    }
  }

  cpSync(sourcePath, destinationPath, { recursive: true });
  rmSync(sourcePath, { recursive: true, force: true });
}

function fetchJson(url) {
  return new Promise((resolvePromise, rejectPromise) => {
    https
        .get(url, (response) => {
          if (response.statusCode && response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
            fetchJson(response.headers.location).then(resolvePromise, rejectPromise);
            return;
          }

          if (response.statusCode !== 200) {
            rejectPromise(new Error(`Failed to fetch ${url}: ${response.statusCode}`));
            return;
          }

          let body = '';
          response.setEncoding('utf8');
          response.on('data', (chunk) => {
            body += chunk;
          });
          response.on('end', () => {
            try {
              resolvePromise(JSON.parse(body));
            } catch (error) {
              rejectPromise(error);
            }
          });
        })
        .on('error', rejectPromise);
  });
}

function downloadFile(url, outputPath) {
  return new Promise((resolvePromise, rejectPromise) => {
    https
        .get(url, (response) => {
          if (response.statusCode && response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
            downloadFile(response.headers.location, outputPath).then(resolvePromise, rejectPromise);
            return;
          }

          if (response.statusCode !== 200) {
            rejectPromise(new Error(`Failed to download ${url}: ${response.statusCode}`));
            return;
          }

          const file = createWriteStream(outputPath);
          response.pipe(file);
          file.on('finish', () => {
            file.close(() => resolvePromise());
          });
          file.on('error', rejectPromise);
        })
        .on('error', rejectPromise);
  });
}

function runCommand(command, args, options = {}) {
  return new Promise((resolvePromise, rejectPromise) => {
    const child = spawn(command, args, {
      cwd: projectRoot,
      stdio: 'inherit',
      shell: false,
      ...options,
    });

    child.on('exit', (code) => {
      if (code === 0) {
        resolvePromise();
        return;
      }
      rejectPromise(new Error(`Command failed: ${command} ${args.join(' ')} (exit ${code})`));
    });
    child.on('error', rejectPromise);
  });
}

async function ensureFlutterSdk() {
  const flutterBinary = join(sdkDir, 'bin', 'flutter');
  if (existsSync(flutterBinary)) {
    return flutterBinary;
  }

  rmSync(sdkDir, { recursive: true, force: true });

  const releases = await fetchJson(
    'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json',
  );
  const stableHash = releases.current_release?.stable;
  const stableRelease = releases.releases?.find((release) => release.hash === stableHash);

  if (!stableRelease?.archive) {
    throw new Error('Could not resolve latest stable Flutter archive');
  }

  const archiveUrl = `https://storage.googleapis.com/flutter_infra_release/releases/${stableRelease.archive}`;
  const archivePath = join(tempDir, 'flutter-sdk.tar.xz');
  const extractRoot = join(tempDir, `flutter-extract-${Date.now()}`);

  await mkdir(tempDir, { recursive: true });
  await mkdir(extractRoot, { recursive: true });
  await downloadFile(archiveUrl, archivePath);
  await runCommand('tar', ['-xJf', archivePath, '-C', extractRoot]);

  moveDirectorySafe(join(extractRoot, 'flutter'), sdkDir);
  rmSync(extractRoot, { recursive: true, force: true });
  return flutterBinary;
}

async function main() {
  await mkdir(buildHomeDir, { recursive: true });
  await mkdir(pubCacheDir, { recursive: true });
  await mkdir(xdgConfigDir, { recursive: true });

  const flutterBinary = await ensureFlutterSdk();
  const env = {
    ...process.env,
    HOME: buildHomeDir,
    PUB_CACHE: pubCacheDir,
    XDG_CONFIG_HOME: xdgConfigDir,
    CI: 'true',
    BOT: 'true',
    FLUTTER_SUPPRESS_ANALYTICS: 'true',
    PATH: `${join(sdkDir, 'bin')}:${process.env.PATH ?? ''}`,
  };

  await runCommand('git', ['config', '--global', '--add', 'safe.directory', sdkDir], { env });
  await runCommand(flutterBinary, ['--version'], { env });
  await runCommand(flutterBinary, ['config', '--enable-web'], { env });
  await runCommand(flutterBinary, ['pub', 'get'], { env });
  await runCommand(flutterBinary, ['build', 'web', '--release'], { env });
}

main().catch((error) => {
  console.error('[vercel-build] failed:', error);
  process.exit(1);
});
