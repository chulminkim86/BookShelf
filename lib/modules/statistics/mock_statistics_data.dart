/// 통계 화면 레이아웃 확인용 샘플 데이터.
/// 실제 책 데이터(서재/책 상세)와 아직 연결되지 않았다 — 저장 기능이 붙으면 교체 예정.

const mockTotalBooks = 15;
const mockTotalSpent = 246000; // 원

const mockAverageRating = 3.8;

/// 서재의 기본 장르 8종과 순서를 맞췄다 (장르 선택기 참고).
const mockGenreDistribution = <String, int>{
  '로맨스': 3,
  'SF': 2,
  '추리/미스터리': 2,
  '판타지': 3,
  '자기계발': 1,
  '에세이/인문': 2,
  '역사': 1,
  '과학/교양': 1,
};

/// 책 상세의 기본 보관장소 4종과 맞췄다.
const mockLocationCounts = <String, int>{
  '서재': 7,
  '거실': 4,
  '현관 앞 책꽂이': 2,
  '연구실': 2,
};

/// 최근 6개월간 "다 읽은 날" 기준 완독 권수.
const mockMonthlyReadCounts = <MapEntry<String, int>>[
  MapEntry('4월', 1),
  MapEntry('5월', 2),
  MapEntry('6월', 1),
  MapEntry('7월', 3),
  MapEntry('8월', 2),
  MapEntry('9월', 1),
];

/// 책에 붙인 태그를 전부 모아서 센 것 (한 책에 여러 태그가 붙을 수 있음).
const mockTagCounts = <String, int>{
  '인생책': 4,
  '스테디셀러': 3,
  '2026추천': 2,
  '기억에남는': 2,
  '선물받음': 1,
};

/// "구매일자" 기준으로 가장 많이 산 달.
const mockMostPurchasedMonth = MapEntry('9월', 4);

/// 책산(Tsundoku): "다 읽은 날"이 있으면 읽음, 없으면 아직 안 읽음(TBR).
/// 두 값의 합이 mockTotalBooks와 같다.
const mockReadCount = 9;
const mockTbrCount = 6;

/// 아직 안 읽은 책 중, 구매일 기준으로 가장 오래 쌓여있는 책 (경과 일수).
const mockLongestOnTbr = <String, int>{
  '스마트워크 바이블': 210,
  '역행자': 150,
  '연금술사': 95,
  '언어의 온도': 60,
  '작별하지 않는다': 30,
};

/// 장르별로 마지막 완독("다 읽은 날")이 며칠 전이었는지.
/// 값이 클수록 그 장르를 오랫동안 안 읽었다는 뜻 — 다음 추천에 참고.
const mockGenreNeglectDays = <String, int>{
  '역사': 180,
  '과학/교양': 120,
  '자기계발': 90,
  '추리/미스터리': 45,
  '에세이/인문': 20,
  '판타지': 10,
  'SF': 5,
  '로맨스': 2,
};

/// 연도별로 그 해 처음 읽은 저자 수.
const mockNewAuthorsByYear = <MapEntry<String, int>>[
  MapEntry('2022', 3),
  MapEntry('2023', 5),
  MapEntry('2024', 4),
  MapEntry('2025', 6),
  MapEntry('2026', 3),
];
