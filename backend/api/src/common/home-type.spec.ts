import { describe, it, expect } from 'vitest';
import { homeTypeLabelToEnum, homeTypeEnumToLabel } from './home-type.js';

describe('home type mappers', () => {
  it('maps every Thai label to its enum and back', () => {
    const pairs: [string, string][] = [
      ['บ้านเดี่ยว', 'detached_house'],
      ['ทาวน์โฮม/ทาวน์เฮ้าส์', 'townhouse'],
      ['คอนโดมิเนียม', 'condo'],
      ['อพาร์ทเม้นท์/ห้องเช่า', 'apartment'],
    ];
    for (const [label, value] of pairs) {
      expect(homeTypeLabelToEnum(label)).toBe(value);
      expect(homeTypeEnumToLabel(value)).toBe(label);
    }
  });

  it('returns null for missing or unrecognised labels', () => {
    expect(homeTypeLabelToEnum(null)).toBeNull();
    expect(homeTypeLabelToEnum(undefined)).toBeNull();
    expect(homeTypeLabelToEnum('')).toBeNull();
    expect(homeTypeLabelToEnum('ปราสาท')).toBeNull();
  });

  it('falls back to บ้านเดี่ยว for missing or unrecognised enums', () => {
    expect(homeTypeEnumToLabel(null)).toBe('บ้านเดี่ยว');
    expect(homeTypeEnumToLabel(undefined)).toBe('บ้านเดี่ยว');
    expect(homeTypeEnumToLabel('castle')).toBe('บ้านเดี่ยว');
  });
});
