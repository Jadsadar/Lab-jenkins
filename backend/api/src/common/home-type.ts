// แปลงระหว่าง enum home_type ใน DB กับข้อความไทยที่ frontend ใช้ตรง ๆ
// (lib/data/mock_data.dart -> homeTypes) ต้องตรงกันทั้ง 2 ทิศเสมอ
const LABEL_TO_ENUM: Record<string, string> = {
  บ้านเดี่ยว: 'detached_house',
  'ทาวน์โฮม/ทาวน์เฮ้าส์': 'townhouse',
  คอนโดมิเนียม: 'condo',
  'อพาร์ทเม้นท์/ห้องเช่า': 'apartment',
};

const ENUM_TO_LABEL: Record<string, string> = Object.fromEntries(
  Object.entries(LABEL_TO_ENUM).map(([label, value]) => [value, label]),
);

export function homeTypeLabelToEnum(label: string | null | undefined): string | null {
  if (!label) return null;
  return LABEL_TO_ENUM[label] ?? null;
}

export function homeTypeEnumToLabel(value: string | null | undefined): string {
  if (!value) return 'บ้านเดี่ยว';
  return ENUM_TO_LABEL[value] ?? 'บ้านเดี่ยว';
}
