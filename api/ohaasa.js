const OHAASA_PAGE_URL = 'https://www.asahi.co.jp/ohaasa/week/horoscope/index.html';
const OHAASA_DATA_URL = 'https://www.asahi.co.jp/data/ohaasa2020/horoscope.json';

const ZODIAC_BY_STATUS = {
  '01': { zodiacKey: 'aries', zodiacJa: 'おひつじ座', zodiacKo: '양자리' },
  '02': { zodiacKey: 'taurus', zodiacJa: 'おうし座', zodiacKo: '황소자리' },
  '03': { zodiacKey: 'gemini', zodiacJa: 'ふたご座', zodiacKo: '쌍둥이자리' },
  '04': { zodiacKey: 'cancer', zodiacJa: 'かに座', zodiacKo: '게자리' },
  '05': { zodiacKey: 'leo', zodiacJa: 'しし座', zodiacKo: '사자자리' },
  '06': { zodiacKey: 'virgo', zodiacJa: 'おとめ座', zodiacKo: '처녀자리' },
  '07': { zodiacKey: 'libra', zodiacJa: 'てんびん座', zodiacKo: '천칭자리' },
  '08': { zodiacKey: 'scorpio', zodiacJa: 'さそり座', zodiacKo: '전갈자리' },
  '09': { zodiacKey: 'sagittarius', zodiacJa: 'いて座', zodiacKo: '사수자리' },
  '10': { zodiacKey: 'capricorn', zodiacJa: 'やぎ座', zodiacKo: '염소자리' },
  '11': { zodiacKey: 'aquarius', zodiacJa: 'みずがめ座', zodiacKo: '물병자리' },
  '12': { zodiacKey: 'pisces', zodiacJa: 'うお座', zodiacKo: '물고기자리' },
};

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
    ['オセロで遊ぶ', '가벼운 게임 한 판 하기'],
    ['２番目に空いているレジに並ぶ', '조금 덜 붐비는 줄 선택하기'],
    ['好きな歌詞をメモする', '좋아하는 가사 한 줄 적기'],
    ['鶏肉を食べる', '단백질 챙겨 먹기'],
    ['ドライブをする', '잠깐 바람 쐬기'],
    ['こっそりガッツポーズをする', '작게 스스로 응원해주기'],
    ['テーマパークに行く', '기분 전환되는 장소 떠올리기'],
    ['腕時計をいつもと反対側につける', '평소와 반대로 작은 변화를 주기'],
  ];

  return replaceAllKeywords(text, dictionary);
}

function translateJaToEnFallback(text) {
  const original = cleanWhitespace(text);
  const dictionary = [
    ['新たな世界が広がる時', 'A new mood is opening up'],
    ['いろいろな角度から物事を見よう', 'Try looking at things from different angles'],
    ['普段読まない分野の本もオススメ', 'A book outside your usual taste could be nice'],
    ['周囲から注目されるかも', 'You may get a little more attention today'],
    ['温めていた企画を発表してみては？', 'It may be a good time to share your idea'],
    ['ちょっとした節約で金運ＵＰ', 'A small saving move could help your money luck'],
    ['通信費の見直しにツキあり', 'Reviewing fixed expenses may go well'],
    ['何でも効率よくこなせる日', 'Things can flow smoothly today'],
    ['誰よりも早く作業に取りかかって', 'Starting a bit earlier will help'],
    ['皆の人気者になれそう♪', 'Your vibe may feel extra warm and likable'],
    ['聞き上手を心掛けてね', 'Listening well will work better than talking more'],
    ['苦手な事を克服できる予感', 'Something difficult may feel more manageable'],
    ['上手にコツをつかめるよ', 'You can catch the rhythm faster than expected'],
    ['恋のパワーがみなぎり活発に', 'Your emotional energy feels lively'],
    ['落ち着いてチャンスを狙ってね', 'Stay calm and wait for the right moment'],
    ['ケアレスミスに注意が必要', 'Watch out for small mistakes'],
    ['丁寧な確認を行うようにして', 'A careful check will help'],
    ['一人で解決できない問題が発生', 'Something may be hard to solve alone'],
    ['先輩や上司に相談すると◎', 'Asking for help could work well'],
    ['あれこれ考えすぎてグッタリ', 'Overthinking may drain your energy'],
    ['もう少し気楽に構えて大丈夫', 'It is okay to take it more lightly'],
    ['人づきあいを面倒に感じるかも', 'Social energy may feel low today'],
    ['好きな音楽を聴いてリフレッシュ', 'Refresh with music you love'],
    ['相手の言葉に振り回されそう', 'Do not let other people’s words shake you'],
    ['根拠のないうわさ話などは', 'Do not take vague rumors too seriously'],
    ['聞き流すのが一番だよ', 'Letting it pass is best'],
    ['丁寧に髪をブラッシングする', 'Brush your hair with care'],
    ['ひじきを食べる', 'Eat some seaweed'],
    ['部屋に花を飾る', 'Put flowers in your room'],
    ['オセロで遊ぶ', 'Play a light game'],
    ['２番目に空いているレジに並ぶ', 'Pick the second shortest line'],
    ['好きな歌詞をメモする', 'Write down a lyric you love'],
    ['鶏肉を食べる', 'Eat some chicken'],
    ['ドライブをする', 'Go for a short drive'],
    ['こっそりガッツポーズをする', 'Give yourself a tiny victory pose'],
    ['テーマパークに行く', 'Think of a fun escape'],
    ['腕時計をいつもと反対側につける', 'Try a tiny switch in your routine'],
  ];

  const direct = replaceAllKeywords(original, dictionary);
  if (direct !== original && !containsJapanese(direct)) {
    return direct;
  }

  const actionObjectDictionary = [
    ['グレーの小物', 'a gray accessory'],
    ['好きな歌詞', 'a lyric you love'],
    ['好きな音楽', 'music you love'],
    ['テーマパーク', 'a fun place'],
    ['腕時計', 'your watch'],
    ['部屋に花', 'flowers in your room'],
    ['花', 'flowers'],
    ['ひじき', 'hijiki'],
    ['鶏肉', 'chicken'],
    ['ドライブ', 'a short drive'],
    ['オセロ', 'a quick game'],
    ['２番目に空いているレジ', 'the second shortest line'],
  ];

  const translateActionObject = (value) => {
    let output = cleanWhitespace(value);
    for (const [source, target] of actionObjectDictionary) {
      output = output.split(source).join(target);
    }
    return cleanWhitespace(output);
  };

  const patterns = [
    [/^(.+)を持ち歩く$/, (match) => `Carry ${translateActionObject(match[1])} with you`],
    [/^(.+)を食べる$/, (match) => `Eat ${translateActionObject(match[1])}`],
    [/^(.+)をする$/, (match) => `Try ${translateActionObject(match[1])}`],
    [/^(.+)に行く$/, (match) => `Go to ${translateActionObject(match[1])}`],
    [/^(.+)をメモする$/, (match) => `Write down ${translateActionObject(match[1])}`],
    [/^(.+)を飾る$/, (match) => `Place ${translateActionObject(match[1])}`],
    [/^(.+)に並ぶ$/, (match) => `Stand in ${translateActionObject(match[1])}`],
    [/^(.+)を聴いてリフレッシュ$/, (match) => `Refresh with ${translateActionObject(match[1])}`],
    [/^(.+)をいつもと反対側につける$/, (match) => `Wear ${translateActionObject(match[1])} on the opposite side`],
  ];

  for (const [pattern, formatter] of patterns) {
    const matched = original.match(pattern);
    if (!matched) {
      continue;
    }

    const translated = cleanWhitespace(formatter(matched));
    if (translated && !containsJapanese(translated)) {
      return translated;
    }
  }

  return null;
}

async function translateWithDeepL(text, targetLang, dateKey) {
  if (!text) {
    return '';
  }

  const apiKey = process.env.DEEPL_API_KEY;
  if (!apiKey) {
    console.error('[api/ohaasa] DEEPL_API_KEY is missing');
    return null;
  }

  const cacheKey = cacheKeyForTranslation({
    dateKey,
    targetLang,
    text,
  });
  const cachedValue = dailyTranslationCache.get(cacheKey);
  if (cachedValue) {
    return cachedValue;
  }

  try {
    const body = new URLSearchParams({
      text,
      source_lang: 'JA',
      target_lang: targetLang,
    });

    const response = await fetch('https://api-free.deepl.com/v2/translate', {
      method: 'POST',
      headers: {
        Authorization: `DeepL-Auth-Key ${apiKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body.toString(),
    });

    if (!response.ok) {
      console.error(
        `[api/ohaasa] DeepL request failed (${targetLang})`,
        response.status,
      );
      return null;
    }

    const payload = await response.json();
    const translatedText = cleanWhitespace(
      payload?.translations?.[0]?.text,
    );

    if (!translatedText) {
      return null;
    }

    dailyTranslationCache.set(cacheKey, translatedText);
    return translatedText;
  } catch (error) {
    console.error(`[api/ohaasa] DeepL translation failed (${targetLang})`, error);
    return null;
  }
}

async function translateWithFallback(text, dateKey) {
  const original = normalizeSourceText(text);
  const [translatedKo, translatedEn] = await Promise.all([
    translateWithDeepL(original, 'KO', dateKey),
    translateWithDeepL(original, 'EN', dateKey),
  ]);
  const cleanKo =
    translatedKo && !containsJapanese(translatedKo)
      ? cleanWhitespace(translatedKo)
      : null;
  const cleanEn =
    translatedEn && !containsJapanese(translatedEn)
      ? cleanWhitespace(translatedEn)
      : null;
  const fallbackKoRaw = translateJaToKoFallback(original);
  const fallbackEnRaw = translateJaToEnFallback(original);
  const fallbackKo =
    fallbackKoRaw && !containsJapanese(fallbackKoRaw)
      ? cleanWhitespace(fallbackKoRaw)
      : null;
  const fallbackEn =
    fallbackEnRaw && !containsJapanese(fallbackEnRaw)
      ? cleanWhitespace(fallbackEnRaw)
      : null;

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

function formatDate(rawDate) {
  const normalized = normalizeDateKey(rawDate);
  if (!normalized) {
    return null;
  }

  return normalized;
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

function dedupePayloadByDate(payload) {
  const deduped = new Map();

  for (const item of payload) {
    const normalizedDate = normalizeDateKey(item?.onair_date);
    if (!normalizedDate) {
      continue;
    }

    const existing = deduped.get(normalizedDate);
    const currentId = Number(item?.horoscope_id ?? 0);
    const existingId = Number(existing?.horoscope_id ?? 0);

    if (!existing || currentId >= existingId) {
      deduped.set(normalizedDate, item);
    }
  }

  return [...deduped.values()];
}

function dedupeRankings(rankings) {
  const deduped = new Map();

  for (const ranking of rankings) {
    const key = ranking?.zodiacKey;
    if (!key) {
      continue;
    }

    const existing = deduped.get(key);
    if (!existing || Number(ranking.rank) < Number(existing.rank)) {
      deduped.set(key, ranking);
    }
  }

  return [...deduped.values()].sort((a, b) => a.rank - b.rank);
}

function parseHoroscopeText(rawText) {
  const parts = String(rawText ?? '')
    .split('\t')
    .map((part) => part.trim())
    .filter(Boolean);

  if (parts.length === 0) {
    return { message: '', action: '' };
  }

  if (parts.length === 1) {
    return { message: parts[0], action: '' };
  }

  return {
    message: parts.slice(0, -1).join('\n'),
    action: parts.at(-1) ?? '',
  };
}

async function normalizeRanking(detail, dateKey) {
  const zodiac = ZODIAC_BY_STATUS[String(detail.horoscope_st).padStart(2, '0')];
  if (!zodiac) {
    return null;
  }

  const parsed = parseHoroscopeText(detail.horoscope_text);
  const [rawMessageTranslations, rawActionTranslations] = await Promise.all([
    translateWithFallback(parsed.message, dateKey),
    translateWithFallback(parsed.action, dateKey),
  ]);
  const messageTranslations = finalizeTranslationTone(rawMessageTranslations);
  const actionTranslations = finalizeTranslationTone(rawActionTranslations, {
    isAction: true,
  });

  return {
    rank: Number(detail.ranking_no),
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

function latestEntryFromPayload(payload) {
  if (!Array.isArray(payload) || payload.length === 0) {
    return null;
  }

  return [...payload].sort((a, b) => {
    return String(b?.onair_date ?? '').localeCompare(String(a?.onair_date ?? ''));
  })[0];
}

module.exports = async function handler(request, response) {
  if (request.method !== 'GET') {
    return response.status(405).json({
      error: 'method_not_allowed',
    });
  }

  try {
    const fetchTimestamp = new Date().toISOString();
    console.info('[api/ohaasa] fetching official page and data', {
      fetchTimestamp,
    });

    const [pageResponse, dataResponse] = await Promise.all([
      fetch(OHAASA_PAGE_URL, {
        headers: { 'user-agent': 'morning-ohasa-vercel/1.0' },
      }),
      fetch(OHAASA_DATA_URL, {
        headers: { accept: 'application/json', 'user-agent': 'morning-ohasa-vercel/1.0' },
      }),
    ]);

    if (!pageResponse.ok) {
      console.error('[api/ohaasa] page fetch failed', pageResponse.status);
      return response.status(502).json({
        error: 'source_page_fetch_failed',
        source: 'ohaasa',
      });
    }

    if (!dataResponse.ok) {
      console.error('[api/ohaasa] data fetch failed', dataResponse.status);
      return response.status(502).json({
        error: 'source_data_fetch_failed',
        source: 'ohaasa',
      });
    }

    const [pageHtml, payload] = await Promise.all([
      pageResponse.text(),
      dataResponse.json(),
    ]);

    if (!pageHtml.includes('今日の星占いランキング')) {
      console.error('[api/ohaasa] unexpected page markup');
      return response.status(502).json({
        error: 'source_page_parse_failed',
        source: 'ohaasa',
      });
    }

    const dedupedPayload = dedupePayloadByDate(payload);
    const latestEntry = latestEntryFromPayload(dedupedPayload);
    if (!latestEntry || !Array.isArray(latestEntry.detail)) {
      console.error('[api/ohaasa] no ranking detail found');
      return response.status(502).json({
        error: 'source_data_parse_failed',
        source: 'ohaasa',
      });
    }

    const sourceDates = [...new Set(
      payload.map((item) => String(item?.onair_date ?? 'unknown')),
    )];
    const sameDayEntries = payload.filter(
      (item) => String(item?.onair_date ?? '') === String(latestEntry.onair_date ?? ''),
    ).length;
    console.info('[api/ohaasa] source audit', {
      fetchTimestamp,
      payloadCount: Array.isArray(payload) ? payload.length : 0,
      dedupedPayloadCount: dedupedPayload.length,
      sourceDates,
      selectedSourceDate: String(latestEntry.onair_date ?? ''),
      sameDayEntries,
    });

    const rankings = dedupeRankings((
      await Promise.all(
        latestEntry.detail.map((detail) =>
          normalizeRanking(detail, String(latestEntry.onair_date ?? 'unknown')),
        ),
      )
    ).filter(Boolean));

    if (rankings.length === 0) {
      console.error('[api/ohaasa] normalized ranking list is empty');
      return response.status(502).json({
        error: 'source_data_parse_failed',
        source: 'ohaasa',
      });
    }

    console.info('[api/ohaasa] response audit', {
      fetchTimestamp,
      sourceDate: String(latestEntry.onair_date ?? ''),
      parsedDate: formatDate(latestEntry.onair_date),
      rankingCount: rankings.length,
      firstRank: rankings[0]?.rank,
      firstZodiacKey: rankings[0]?.zodiacKey,
    });

    return response.status(200).json({
      date: formatDate(latestEntry.onair_date),
      source: 'ohaasa',
      sourcePageUrl: OHAASA_PAGE_URL,
      sourceDataUrl: OHAASA_DATA_URL,
      rankings,
    });
  } catch (error) {
    console.error('[api/ohaasa] unexpected failure', error);
    return response.status(500).json({
      error: 'internal_error',
      source: 'ohaasa',
    });
  }
};
