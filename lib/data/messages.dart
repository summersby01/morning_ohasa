const Map<String, List<String>> todayMessagesByLanguage = <String, List<String>>{
  'ko': <String>[
    '완벽하게보다 끝내는 쪽이 더 중요해',
    '작게 시작해도 흐름은 바뀔 수 있어',
    '오늘은 속도보다 리듬을 믿어봐',
    '하나만 정리해도 마음이 가벼워져',
    '무리해서 웃기보다 편하게 있어도 돼',
    '오늘은 덜어내는 쪽이 더 잘 맞아',
    '지금의 선택이 오래 남을 수 있어',
    '작은 확신 하나가 하루를 버티게 해줘',
    '천천히 해도 방향만 맞으면 괜찮아',
    '마음이 복잡할수록 한 가지만 남겨보자',
  ],
  'en': <String>[
    'Finishing one thing matters more today.',
    'A small start can change the flow.',
    'Trust your pace over pure speed today.',
    'Clearing one thing can lighten your mind.',
    'You do not need to force a bright mood.',
    'Less may work better than more today.',
    'Today’s choice may last longer than expected.',
    'One small bit of confidence can carry the day.',
    'Slow is fine if the direction is right.',
    'Keep one clear priority when things feel noisy.',
  ],
};

const Map<String, List<String>> actionRecommendationsByLanguage =
    <String, List<String>>{
      'ko': <String>[
        '물 한 잔 천천히 마시기',
        '할 일 하나만 먼저 끝내기',
        '창문 열고 5분 환기하기',
        '핸드폰 10분 내려놓기',
        '좋아하는 노래 1곡 듣기',
        '산책 10분만 다녀오기',
        '오늘 일정 다시 가볍게 정리하기',
        '미뤄둔 답장 하나 보내기',
        '책 5쪽만 읽기',
        '자리에서 잠깐 스트레칭하기',
      ],
      'en': <String>[
        'Drink a glass of water slowly',
        'Finish one task first',
        'Open a window for five minutes',
        'Put your phone down for ten minutes',
        'Play one favorite song',
        'Take a short ten-minute walk',
        'Lightly reset today’s schedule',
        'Send one delayed reply',
        'Read five pages of a book',
        'Stretch for a moment where you are',
      ],
    };

const Map<String, Map<String, List<String>>> zodiacSpecificMessagesByLanguage =
    <String, Map<String, List<String>>>{
      'ko': <String, List<String>>{
        'aries': <String>[
          '힘으로 밀기보다 첫 방향을 예쁘게 잡아봐',
          '시작 에너지는 충분하니 조절감이 포인트야',
        ],
        'taurus': <String>[
          '익숙한 루틴이 오늘 마음을 단단하게 잡아줘',
          '천천히 가도 네 감각은 꽤 정확해',
        ],
        'gemini': <String>[
          '생각이 흩어질수록 한 문장 요약이 힘이 돼',
          '말센스보다 핵심 정리가 더 잘 통할 거야',
        ],
        'cancer': <String>[
          '마음을 먼저 챙길수록 하루가 덜 흔들려',
          '포근한 분위기가 생각보다 큰 힘이 돼',
        ],
        'leo': <String>[
          '즐기는 태도가 더 빛나는 날이야',
          '자연스러운 여유가 더 예뻐 보여',
        ],
        'virgo': <String>[
          '완벽한 계획보다 끝낼 수 있는 계획이 좋아',
          '작은 마무리가 만족을 줄 수 있어',
        ],
        'libra': <String>[
          '선택지를 덜어낼수록 더 예쁘게 정리돼',
          '분위기보다 기준 잡는 쪽이 잘 맞아',
        ],
        'scorpio': <String>[
          '하나만 제대로 잡아도 충분해',
          '몰입과 휴식을 같이 챙겨야 오래가',
        ],
        'sagittarius': <String>[
          '새로운 공기가 답이 될 수 있어',
          '오늘 가능한 모험만 해도 충분해',
        ],
        'capricorn': <String>[
          '꾸준함이 가장 세게 먹히는 날이야',
          '작은 진전이지만 오늘은 그게 제일 믿을 만해',
        ],
        'aquarius': <String>[
          '다른 시선 하나가 오늘의 핵심이 될 수 있어',
          '조금 달라도 괜찮아',
        ],
        'pisces': <String>[
          '좋아하는 분위기를 먼저 만들자',
          '취향을 따르는 선택이 마음을 편하게 해줘',
        ],
      },
      'en': <String, List<String>>{
        'aries': <String>[
          'Set the direction before pushing harder.',
          'Your start is strong, so pace matters.',
        ],
        'taurus': <String>[
          'A familiar routine can steady you today.',
          'Slow is fine because your instincts are solid.',
        ],
        'gemini': <String>[
          'A one-line summary can help when thoughts scatter.',
          'Clear points will work better than clever words.',
        ],
        'cancer': <String>[
          'Taking care of your mood first will help the day.',
          'A softer atmosphere may give you more strength.',
        ],
        'leo': <String>[
          'Enjoying the moment will shine more than showing off.',
          'Easy confidence will look better than extra force.',
        ],
        'virgo': <String>[
          'A finishable plan will beat a perfect one.',
          'Small clean endings can feel satisfying today.',
        ],
        'libra': <String>[
          'Fewer options may make the choice clearer.',
          'Setting the standard may suit you better today.',
        ],
        'scorpio': <String>[
          'One deep focus is enough today.',
          'Protect your focus, but keep room for rest.',
        ],
        'sagittarius': <String>[
          'Fresh air or a new scene may help.',
          'A small adventure is enough for today.',
        ],
        'capricorn': <String>[
          'Steady effort will work best today.',
          'A small step forward is still worth trusting.',
        ],
        'aquarius': <String>[
          'A different angle may become the key today.',
          'It is okay if your way looks a little different.',
        ],
        'pisces': <String>[
          'Build the mood you want first.',
          'Following your taste may feel most comfortable today.',
        ],
      },
    };
