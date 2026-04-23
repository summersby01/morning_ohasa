const OHAASA_HOROSCOPE_PAGE_URL =
  'https://www.asahi.co.jp/ohaasa/week/horoscope/index.html';
const OHAASA_HOROSCOPE_JSON_URL =
  'https://www.asahi.co.jp/data/ohaasa2020/horoscope.json';

const ZODIACS = [
  { zodiacKey: 'aries', zodiacJa: 'おひつじ座', zodiacKo: '양자리', sourceCode: '01' },
  { zodiacKey: 'taurus', zodiacJa: 'おうし座', zodiacKo: '황소자리', sourceCode: '02' },
  { zodiacKey: 'gemini', zodiacJa: 'ふたご座', zodiacKo: '쌍둥이자리', sourceCode: '03' },
  { zodiacKey: 'cancer', zodiacJa: 'かに座', zodiacKo: '게자리', sourceCode: '04' },
  { zodiacKey: 'leo', zodiacJa: 'しし座', zodiacKo: '사자자리', sourceCode: '05' },
  { zodiacKey: 'virgo', zodiacJa: 'おとめ座', zodiacKo: '처녀자리', sourceCode: '06' },
  { zodiacKey: 'libra', zodiacJa: 'てんびん座', zodiacKo: '천칭자리', sourceCode: '07' },
  { zodiacKey: 'scorpio', zodiacJa: 'さそり座', zodiacKo: '전갈자리', sourceCode: '08' },
  { zodiacKey: 'sagittarius', zodiacJa: 'いて座', zodiacKo: '사수자리', sourceCode: '09' },
  { zodiacKey: 'capricorn', zodiacJa: 'やぎ座', zodiacKo: '염소자리', sourceCode: '10' },
  { zodiacKey: 'aquarius', zodiacJa: 'みずがめ座', zodiacKo: '물병자리', sourceCode: '11' },
  { zodiacKey: 'pisces', zodiacJa: 'うお座', zodiacKo: '물고기자리', sourceCode: '12' },
];

const ZODIAC_BY_JA = new Map(ZODIACS.map((zodiac) => [zodiac.zodiacJa, zodiac]));
const ZODIAC_BY_SOURCE_CODE = new Map(
  ZODIACS.map((zodiac) => [zodiac.sourceCode, zodiac]),
);
const ZODIAC_NAME_PATTERN = new RegExp(
  `^(${ZODIACS.map((zodiac) => zodiac.zodiacJa).join('|')})$`,
);
const ZODIAC_SECTION_PATTERN = new RegExp(
  `^(${ZODIACS.map((zodiac) => zodiac.zodiacJa).join('|')})\\(`,
);

const dailyTranslationCache = new Map();

function cacheKeyForTranslation({ dateKey, targetLang, text }) {
  return `${dateKey}:${targetLang}:${text}`;
}

function decodeHtmlEntities(text) {
  return String(text ?? '')
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&quot;/gi, '"')
    .replace(/&#39;|&apos;/gi, '\'');
}

function cleanupTranslatedText(text) {
  return decodeHtmlEntities(text)
    .replace(/\r\n/g, '\n')
    .replace(/[ \t]+\n/g, '\n')
    .replace(/\n[ \t]+/g, '\n')
    .replace(/[ \t]{2,}/g, ' ')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

function cleanWhitespace(text) {
  return cleanupTranslatedText(text);
}

function normalizeSourceText(text) {
  return cleanWhitespace(
    String(text ?? '')
      .replace(/◎/g, 'おすすめ')
      .replace(/○/g, 'ふつう')
      .replace(/△/g, '慎重に')
      .replace(/×/g, '注意')
      .replace(/◯/g, 'おすすめ'),
  );
}

function normalizeSymbolsKo(text) {
  return cleanWhitespace(
    String(text ?? '')
      .replace(/◎/g, '좋아')
      .replace(/○|◯/g, '무난해')
      .replace(/△/g, '조금 신중하게 가는 게 좋아')
      .replace(/×/g, '주의가 필요해')
      .replace(/[♪☆★♡♥!！]{2,}/g, '')
      .replace(/[♪☆★♡♥]/g, ''),
  );
}

function normalizeSymbolsEn(text) {
  return cleanWhitespace(
    String(text ?? '')
      .replace(/◎/g, 'good')
      .replace(/○|◯/g, 'fine')
      .replace(/△/g, 'take it easy')
      .replace(/×/g, 'be careful')
      .replace(/[♪☆★♡♥!！]{2,}/g, '')
      .replace(/[♪☆★♡♥]/g, ''),
  );
}

function removeLeftoverJapanese(text) {
  return cleanWhitespace(
    String(text ?? '').replace(/[\u3040-\u30ff\u3400-\u9fff々〆ヵヶ]/g, ' '),
  );
}

function polishKoreanTone(text, { isAction = false } = {}) {
  let output = cleanWhitespace(text);

  const replacements = [
    ['바라보자', '바라봐'],
    ['점검에 운이 있어', '가볍게 점검해봐도 좋아'],
    ['흐름을 잡기 쉬워', '흐름 잡기 좋아'],
    ['도움 요청이 오히려 더 빨라', '도움 요청해봐도 괜찮아'],
    ['가볍게 생각해도 괜찮아', '조금 가볍게 생각해도 괜찮아'],
    ['기분을 환기하자', '기분 환기해봐'],
    ['중요해', '중요할 수 있어'],
    ['체크하자', '체크해봐'],
    ['확인하자', '확인해봐'],
    ['타이밍을 보자', '타이밍 봐도 좋아'],
    ['챙겨 먹기', '챙겨 먹어봐'],
    ['정리해보기', '정리해봐'],
    ['한 판 하기', '가볍게 해봐'],
    ['선택하기', '골라봐'],
    ['적기', '적어봐'],
    ['쐬기', '쐬어봐'],
    ['떠올리기', '떠올려봐'],
    ['주기', '줘봐'],
    ['필요하다.', '필요해'],
    ['중요하다.', '중요해'],
    ['좋다.', '좋아'],
    ['추천한다.', '추천해'],
    ['하는 것이 좋다', '해봐도 좋아'],
    ['하는 게 좋다', '해봐도 좋아'],
    ['할 필요가 있다', '해볼 필요가 있어'],
  ];

  for (const [source, target] of replacements) {
    output = output.split(source).join(target);
  }

  if (isAction) {
    if (!/[.!?…]$/.test(output) && !/(해봐|괜찮아|좋아|봐도 좋아|해도 좋아|해도 괜찮아|추천해)$/.test(output)) {
      output = `${output}해봐`;
    }
  } else if (!/(괜찮아|좋아|좋을 수 있어|해봐|해도 좋아|해도 괜찮아|일 수 있어|수 있어)$/.test(output)) {
    output = `${output}\n괜찮아`;
  }

  return cleanWhitespace(output);
}

function polishEnglishTone(text, { isAction = false } = {}) {
  let output = cleanWhitespace(text);

  const replacements = [
    ['Watch out for ', 'You might want to watch out for '],
    ['A careful check will help', 'A quick check could help'],
    ['Starting a bit earlier will help', 'It’s a good time to start a little earlier'],
    ['Asking for help could work well', 'You might want to ask for help'],
    ['Refresh with music you love', 'Try refreshing with music you love'],
    ['Go for a short drive', 'Try a short drive'],
    ['Put flowers in your room', 'Try putting flowers in your room'],
    ['Eat some ', 'Try having some '],
    ['Carry ', 'Try carrying '],
    ['Write down ', 'Try writing down '],
    ['Place ', 'Try placing '],
    ['Stand in ', 'You might want to join '],
    ['Go to ', 'Try going to '],
    ['Wear ', 'Try wearing '],
    ['It is okay to take it more lightly', 'It’s okay to keep it light'],
    ['Things can flow smoothly today', 'Things might flow a little more smoothly today'],
    ['You may get a little more attention today', 'You might get a little more attention today'],
  ];

  for (const [source, target] of replacements) {
    output = output.split(source).join(target);
  }

  if (isAction) {
    if (!/^(Try |You might |It’s a good time to )/.test(output)) {
      output = `Try ${output.charAt(0).toLowerCase()}${output.slice(1)}`;
    }
  } else if (!/[.!?]$/.test(output)) {
    output = `${output}\nIt’s okay to take it easy.`;
  }

  return cleanWhitespace(output);
}

function postProcessKorean(text, { isAction = false } = {}) {
  const normalized = normalizeSymbolsKo(text);
  const withoutJapanese = removeLeftoverJapanese(normalized);
  return formatForMobile(
    polishKoreanTone(withoutJapanese, { isAction }),
  );
}

function postProcessEnglish(text, { isAction = false } = {}) {
  const normalized = normalizeSymbolsEn(text);
  const withoutJapanese = removeLeftoverJapanese(normalized);
  return formatForMobile(
    polishEnglishTone(withoutJapanese, { isAction }),
  );
}

function formatForMobile(text) {
  const normalized = cleanWhitespace(text);
  if (!normalized) {
    return normalized;
  }

  if (normalized.includes('\n')) {
    return normalized
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean)
      .slice(0, 2)
      .join('\n');
  }

  if (normalized.length > 34) {
    const breakIndex = normalized.lastIndexOf(' ', 34);
    if (breakIndex > 12) {
      return `${normalized.slice(0, breakIndex)}\n${normalized.slice(breakIndex + 1)}`;
    }
  }

  return normalized;
}

function containsJapanese(text) {
  return /[\u3040-\u30ff\u3400-\u9fff]/.test(String(text ?? ''));
}

function replaceAllKeywords(text, dictionary) {
  let output = String(text ?? '');

  for (const [source, target] of dictionary) {
    output = output.split(source).join(target);
  }

  return cleanWhitespace(output);
}

function translateJaToKoFallback(text) {
  const dictionary = [
    ['新たな世界が広がる時', '새로운 가능성이 열리는 날'],
    ['いろいろな角度から物事を見よう', '한 가지보다 여러 관점으로 바라보자'],
    ['普段読まない分野の本もオススメ', '평소 안 읽던 분야를 가볍게 봐도 좋아'],
    ['周囲から注目されるかも', '주변의 시선이 조금 더 모일 수 있어'],
    ['温めていた企画を発表してみては？', '미뤄둔 아이디어를 꺼내보기 좋아'],
    ['ちょっとした節約で金運ＵＰ', '작은 절약이 금전운을 올려줄 수 있어'],
    ['通信費の見直しにツキあり', '고정지출 점검에 운이 있어'],
    ['何でも効率よくこなせる日', '일이 깔끔하게 풀리는 날'],
    ['誰よりも早く作業に取りかかって', '조금 빨리 시작하면 흐름을 잡기 쉬워'],
    ['皆の人気者になれそう♪', '분위기를 부드럽게 이끌 수 있어'],
    ['聞き上手を心掛けてね', '말하기보다 잘 들어주는 쪽이 좋아'],
    ['苦手な事を克服できる予感', '부담스러운 일도 의외로 풀릴 수 있어'],
    ['上手にコツをつかめるよ', '요령이 금방 생길 수 있어'],
    ['恋のパワーがみなぎり活発に', '감정 에너지가 활발하게 흐를 수 있어'],
    ['落ち着いてチャンスを狙ってね', '조급해하지 말고 타이밍을 보자'],
    ['ケアレスミスに注意が必要', '사소한 실수는 한 번 더 체크하자'],
    ['丁寧な確認を行うようにして', '빠르게보다 꼼꼼하게 확인하자'],
    ['一人で解決できない問題が発生', '혼자 풀기 어려운 일이 생길 수 있어'],
    ['先輩や上司に相談すると◎', '도움 요청이 오히려 더 빨라'],
    ['あれこれ考えすぎてグッタリ', '생각이 많아지면 쉽게 지칠 수 있어'],
    ['もう少し気楽に構えて大丈夫', '조금 더 가볍게 생각해도 괜찮아'],
    ['人づきあいを面倒に感じるかも', '사람 관계가 조금 피곤하게 느껴질 수 있어'],
    ['好きな音楽を聴いてリフレッシュ', '좋아하는 음악으로 기분을 환기하자'],
    ['相手の言葉に振り回されそう', '남의 말에 흔들리지 않는 게 중요해'],
    ['根拠のないうわさ話などは', '근거 없는 말은 너무 믿지 말고'],
    ['聞き流すのが一番だよ', '가볍게 흘려보내는 쪽이 좋아'],
    ['丁寧に髪をブラッシングする', '머리를 차분히 정리해보기'],
    ['ひじきを食べる', '해조류를 챙겨 먹기'],
    ['部屋に花を飾る', '작은 꽃이나 식물 두기'],
  ];

  return replaceAllKeywords(text, dictionary);
}

function translateJaToEnFallback(text) {
  const dictionary = [
    ['新たな世界が広がる時', 'A new world may open up today'],
    ['いろいろな角度から物事を見よう', 'Try looking at things from different angles'],
    ['普段読まない分野の本もオススメ', 'A book outside your usual taste could be a good pick'],
    ['周囲から注目されるかも', 'You may draw a bit more attention than usual'],
    ['温めていた企画を発表してみては？', 'This could be a good time to share an idea you have been holding onto'],
    ['ちょっとした節約で金運ＵＰ', 'A small saving habit could help your money luck'],
    ['通信費の見直しにツキあり', 'Reviewing monthly bills could go well'],
    ['何でも効率よくこなせる日', 'You may handle things efficiently today'],
    ['誰よりも早く作業に取りかかって', 'Starting earlier than others could help'],
    ['皆の人気者になれそう♪', 'You could easily become the center of attention'],
    ['聞き上手を心掛けてね', 'Try focusing on listening well'],
    ['苦手な事を克服できる予感', 'You may get through something that usually feels difficult'],
    ['上手にコツをつかめるよ', 'You could quickly get the hang of it'],
    ['恋のパワーがみなぎり活発に', 'Romantic energy may feel especially lively'],
    ['落ち着いてチャンスを狙ってね', 'Stay calm and watch for the right moment'],
    ['ケアレスミスに注意が必要', 'Watch out for small careless mistakes'],
    ['丁寧な確認を行うようにして', 'Take extra time to double-check things'],
    ['一人で解決できない問題が発生', 'A problem that is hard to solve alone may come up'],
    ['先輩や上司に相談すると◎', 'Talking to someone more experienced could help'],
    ['あれこれ考えすぎてグッタリ', 'Overthinking may leave you drained'],
    ['もう少し気楽に構えて大丈夫', 'It is okay to keep things a little lighter'],
    ['人づきあいを面倒に感じるかも', 'Social interactions may feel tiring'],
    ['好きな音楽を聴いてリフレッシュ', 'Refresh yourself with music you like'],
    ['相手の言葉に振り回されそう', 'You may be swayed by what others say'],
    ['根拠のないうわさ話などは', 'Try not to trust baseless rumors'],
    ['聞き流すのが一番だよ', 'It may be best to let it pass'],
    ['丁寧に髪をブラッシングする', 'Brush your hair carefully'],
    ['ひじきを食べる', 'Try eating hijiki seaweed'],
    ['部屋に花を飾る', 'Try placing flowers in your room'],
  ];

  return replaceAllKeywords(text, dictionary);
}

async function translateWithFallback(text, dateKey) {
  const original = normalizeSourceText(text);
  if (!original) {
    return { ja: '', ko: '', en: '' };
  }

  const [translatedKo, translatedEn] = await Promise.all([
    translateText(original, 'ko', dateKey),
    translateText(original, 'en', dateKey),
  ]);

  const cleanKo = translatedKo && !containsJapanese(translatedKo)
    ? cleanWhitespace(translatedKo)
    : '';
  const cleanEn = translatedEn && !containsJapanese(translatedEn)
    ? cleanWhitespace(translatedEn)
    : '';

  const fallbackKo = translateJaToKoFallback(original);
  const fallbackEn = translateJaToEnFallback(original);

  if (translatedKo && !cleanKo) {
    console.error('[api/ohaasa] Korean translation still contains Japanese', {
      dateKey,
      text: original,
      translatedKo,
    });
  }

  if (translatedEn && !cleanEn) {
    console.error('[api/ohaasa] English translation still contains Japanese', {
      dateKey,
      text: original,
      translatedEn,
    });
  }

  if (!cleanKo && !fallbackKo) {
    console.error('[api/ohaasa] Korean translation failed without clean fallback', {
      dateKey,
      text: original,
    });
  }

  if (!cleanEn && !fallbackEn) {
    console.error('[api/ohaasa] English translation failed without clean fallback', {
      dateKey,
      text: original,
    });
  }

  return {
    ja: original,
    ko: cleanKo || fallbackKo || '',
    en: cleanEn || fallbackEn || '',
  };
}

async function translateText(text, targetLang, dateKey) {
  const original = cleanWhitespace(text);
  if (!original) {
    return '';
  }

  const cacheKey = cacheKeyForTranslation({ dateKey, targetLang, text: original });
  if (dailyTranslationCache.has(cacheKey)) {
    return dailyTranslationCache.get(cacheKey);
  }

  try {
    const translationUrl = new URL('https://translate.googleapis.com/translate_a/single');
    translationUrl.searchParams.set('client', 'gtx');
    translationUrl.searchParams.set('sl', 'ja');
    translationUrl.searchParams.set('tl', targetLang);
    translationUrl.searchParams.set('dt', 't');
    translationUrl.searchParams.set('q', original);

    const response = await fetch(translationUrl, {
      headers: { 'user-agent': 'morning-ohasa-vercel/1.0' },
    });

    if (!response.ok) {
      return '';
    }

    const payload = await response.json();
    const translated = Array.isArray(payload?.[0])
      ? payload[0]
        .map((part) => Array.isArray(part) ? String(part[0] ?? '') : '')
        .join('')
      : '';

    const normalized = cleanWhitespace(translated);
    dailyTranslationCache.set(cacheKey, normalized);
    return normalized;
  } catch (error) {
    console.error('[api/ohaasa] translation request failed', {
      targetLang,
      dateKey,
      error: String(error),
    });
    return '';
  }
}

function finalizeTranslationTone(translations, { isAction = false } = {}) {
  return {
    ja: formatForMobile(translations.ja),
    ko: translations.ko
      ? postProcessKorean(translations.ko, { isAction })
      : '',
    en: translations.en
      ? postProcessEnglish(translations.en, { isAction })
      : '',
  };
}

function normalizeDateKey(rawDate) {
  const value = String(rawDate ?? '').trim();
  if (/^\d{8}$/.test(value)) {
    return `${value.slice(0, 4)}-${value.slice(4, 6)}-${value.slice(6, 8)}`;
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  return null;
}

function formatDate(rawDate) {
  return normalizeDateKey(rawDate);
}

function htmlToLines(html) {
  return decodeHtmlEntities(
    String(html ?? '')
      .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, '\n')
      .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, '\n')
      .replace(/<!--[\s\S]*?-->/g, '\n')
      .replace(/<\/(p|div|section|article|li|ul|ol|h1|h2|h3|h4|h5|h6|dt|dd|br)>/gi, '\n')
      .replace(/<[^>]+>/g, '\n'),
  )
    .split('\n')
    .map((line) => cleanWhitespace(line))
    .filter(Boolean);
}

function extractPageDate(lines) {
  for (const line of lines) {
    const match = line.match(/^(\d{1,2})月(\d{1,2})日（[^）]+）の占い$/);
    if (!match) {
      continue;
    }

    const now = new Date();
    const year = String(now.getFullYear());
    const month = match[1].padStart(2, '0');
    const day = match[2].padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  return null;
}

function extractRankingOrder(lines) {
  const startIndex = lines.findIndex((line) => /の占い$/.test(line));
  const endIndex = lines.findIndex((line) => /のナンバーワン$/.test(line));
  const slice = lines.slice(
    startIndex >= 0 ? startIndex + 1 : 0,
    endIndex >= 0 ? endIndex : lines.length,
  );
  const rankedNames = [];
  const seen = new Set();

  for (const line of slice) {
    if (!ZODIAC_NAME_PATTERN.test(line) || seen.has(line)) {
      continue;
    }

    seen.add(line);
    rankedNames.push(line);

    if (rankedNames.length === ZODIACS.length) {
      break;
    }
  }

  if (rankedNames.length !== ZODIACS.length) {
    throw new Error(`ranking_order_parse_failed:${rankedNames.length}`);
  }

  return rankedNames;
}

function extractDetailSections(lines) {
  const sections = new Map();
  let currentSection = null;

  for (const line of lines) {
    const headingMatch = line.match(ZODIAC_SECTION_PATTERN);
    if (headingMatch) {
      const zodiacJa = headingMatch[1];
      currentSection = {
        zodiacJa,
        message: '',
        luckyColor: '',
        action: '',
      };
      sections.set(zodiacJa, currentSection);
      continue;
    }

    if (!currentSection) {
      continue;
    }

    if (!currentSection.message &&
        !line.startsWith('ラッキーカラー：') &&
        !line.startsWith('幸運のカギ：') &&
        !/今日の順位/.test(line) &&
        !ZODIAC_NAME_PATTERN.test(line)) {
      currentSection.message = line;
      continue;
    }

    if (line.startsWith('ラッキーカラー：')) {
      currentSection.luckyColor = line.replace('ラッキーカラー：', '').trim();
      continue;
    }

    if (line.startsWith('幸運のカギ：')) {
      currentSection.action = line.replace('幸運のカギ：', '').trim();
    }
  }

  return sections;
}

async function normalizeRanking({
  rank,
  zodiac,
  detailSection,
  dateKey,
}) {
  const rawMessage = detailSection?.message ?? '';
  const rawAction = detailSection?.action || detailSection?.luckyColor || '';
  const [rawMessageTranslations, rawActionTranslations] = await Promise.all([
    translateWithFallback(rawMessage, dateKey),
    translateWithFallback(rawAction, dateKey),
  ]);
  const messageTranslations = finalizeTranslationTone(rawMessageTranslations);
  const actionTranslations = finalizeTranslationTone(rawActionTranslations, {
    isAction: true,
  });

  return {
    rank,
    zodiacKey: zodiac.zodiacKey,
    zodiacJa: zodiac.zodiacJa,
    zodiacKo: zodiac.zodiacKo,
    messageJa: messageTranslations.ja,
    messageKo: messageTranslations.ko,
    messageEn: messageTranslations.en,
    actionJa: actionTranslations.ja,
    actionKo: actionTranslations.ko,
    actionEn: actionTranslations.en,
  };
}

function extractOhaasaDetailText(rawText) {
  const lines = cleanWhitespace(String(rawText ?? ''))
    .split(/\t|\n/)
    .map((line) => cleanWhitespace(line))
    .filter(Boolean);

  if (lines.length === 0) {
    return {
      message: '',
      action: '',
    };
  }

  if (lines.length === 1) {
    return {
      message: lines[0],
      action: '',
    };
  }

  return {
    message: lines.slice(0, -1).join('\n'),
    action: lines[lines.length - 1],
  };
}

module.exports = async function handler(request, response) {
  if (request.method !== 'GET') {
    return response.status(405).json({
      error: 'method_not_allowed',
    });
  }

  try {
    const fetchTimestamp = new Date().toISOString();
    console.info('[api/ohaasa] fetching ohaasa source json', {
      fetchTimestamp,
      sourcePageUrl: OHAASA_HOROSCOPE_PAGE_URL,
      sourceJsonUrl: OHAASA_HOROSCOPE_JSON_URL,
    });

    const pageResponse = await fetch(OHAASA_HOROSCOPE_JSON_URL, {
      headers: { 'user-agent': 'morning-ohasa-vercel/1.0' },
    });

    if (!pageResponse.ok) {
      console.error('[api/ohaasa] source json fetch failed', pageResponse.status);
      return response.status(502).json({
        error: 'source_page_fetch_failed',
        source: 'asahi-ohaasa',
      });
    }

    const payload = await pageResponse.json();
    const dailyPayload = Array.isArray(payload) ? payload[0] : null;
    const pageDate = normalizeDateKey(dailyPayload?.onair_date);
    const details = Array.isArray(dailyPayload?.detail)
      ? dailyPayload.detail
      : [];

    if (!pageDate || details.length === 0) {
      throw new Error('source_date_parse_failed');
    }

    const sortedDetails = details
      .map((detail) => ({
        ...detail,
        ranking_no: Number.parseInt(String(detail?.ranking_no ?? ''), 10),
        horoscope_st: String(detail?.horoscope_st ?? '').padStart(2, '0'),
      }))
      .filter(
        (detail) =>
          Number.isInteger(detail.ranking_no) &&
          detail.ranking_no > 0 &&
          detail.horoscope_st.length > 0,
      )
      .sort((a, b) => a.ranking_no - b.ranking_no);

    const rankList = sortedDetails.map((detail) => detail.horoscope_st);
    const rankings = await Promise.all(
      sortedDetails.map((detail, index) => {
        const zodiac = ZODIAC_BY_SOURCE_CODE.get(detail.horoscope_st);
        if (!zodiac) {
          throw new Error(`unknown_zodiac_code:${detail.horoscope_st}`);
        }
        const detailText = extractOhaasaDetailText(detail.horoscope_text);

        return normalizeRanking({
          rank: index + 1,
          zodiac,
          detailSection: {
            message: detailText.message,
            action: detailText.action,
            luckyColor: '',
          },
          dateKey: pageDate,
        });
      }),
    );

    console.info('[api/ohaasa] source ranking order', {
      fetchTimestamp,
      sourceDate: pageDate,
      rankList,
      sourceRankings: rankings.map((ranking) => `${ranking.rank}:${ranking.zodiacKey}`),
    });

    return response.status(200).json({
      date: formatDate(pageDate),
      source: 'asahi-ohaasa',
      sourcePageUrl: OHAASA_HOROSCOPE_PAGE_URL,
      sourceJsonUrl: OHAASA_HOROSCOPE_JSON_URL,
      rankings,
    });
  } catch (error) {
    console.error('[api/ohaasa] unexpected failure', error);
    return response.status(500).json({
      error: 'internal_error',
      source: 'asahi-ohaasa',
    });
  }
};
