import { describe, it, expect } from 'vitest';
import {
  genderLabelToDb,
  genderDbToLabel,
  statusLabelToDb,
  statusDbToLabel,
  weightToDb,
  weightDbToLabel,
} from './pet-mappers.js';

describe('gender mappers', () => {
  it('maps Thai labels to DB values', () => {
    expect(genderLabelToDb('ผู้')).toBe('female');
    expect(genderLabelToDb('เมีย')).toBe('female');
  });

  it('falls back to unknown for missing or unrecognised labels', () => {
    expect(genderLabelToDb(undefined)).toBe('unknown');
    expect(genderLabelToDb('')).toBe('unknown');
    expect(genderLabelToDb('อื่น ๆ')).toBe('unknown');
  });

  it('maps DB values back to Thai labels', () => {
    expect(genderDbToLabel('male')).toBe('ผู้');
    expect(genderDbToLabel('female')).toBe('เมีย');
    expect(genderDbToLabel('unknown')).toBe('ผู้');
  });

  it('falls back to ผู้ for null or unrecognised DB values', () => {
    expect(genderDbToLabel(null)).toBe('ผู้');
    expect(genderDbToLabel(undefined)).toBe('ผู้');
    expect(genderDbToLabel('other')).toBe('ผู้');
  });
});

describe('status mappers', () => {
  it('maps Thai labels to DB values', () => {
    expect(statusLabelToDb('ยังไม่ถูกรับเลี้ยง')).toBe('available');
    expect(statusLabelToDb('ถูกรับเลี้ยงแล้ว')).toBe('adopted');
    expect(statusLabelToDb('ยกเลิกประกาศ')).toBe('cancelled');
  });

  it('falls back to available for missing or unrecognised labels', () => {
    expect(statusLabelToDb(undefined)).toBe('available');
    expect(statusLabelToDb('ไม่มีสถานะนี้')).toBe('available');
  });

  it('maps DB values back to Thai labels, treating pending as open', () => {
    expect(statusDbToLabel('available')).toBe('ยังไม่ถูกรับเลี้ยง');
    expect(statusDbToLabel('adopted')).toBe('ถูกรับเลี้ยงแล้ว');
    expect(statusDbToLabel('cancelled')).toBe('ยกเลิกประกาศ');
    expect(statusDbToLabel('pending')).toBe('ยังไม่ถูกรับเลี้ยง');
  });

  it('falls back to the open label for null or unrecognised DB values', () => {
    expect(statusDbToLabel(null)).toBe('ยังไม่ถูกรับเลี้ยง');
    expect(statusDbToLabel(undefined)).toBe('ยังไม่ถูกรับเลี้ยง');
    expect(statusDbToLabel('archived')).toBe('ยังไม่ถูกรับเลี้ยง');
  });
});

describe('weight mappers', () => {
  it('parses positive numeric strings', () => {
    expect(weightToDb('3.2')).toBe(3.2);
    expect(weightToDb('10')).toBe(10);
  });

  it('returns null for missing, non-numeric, zero or negative weights', () => {
    expect(weightToDb(undefined)).toBeNull();
    expect(weightToDb('')).toBeNull();
    expect(weightToDb('-')).toBeNull();
    expect(weightToDb('0')).toBeNull();
    expect(weightToDb('-5')).toBeNull();
  });

  it('formats DB weights as labels', () => {
    expect(weightDbToLabel(3.2)).toBe('3.2');
    expect(weightDbToLabel('4.5')).toBe('4.5');
    expect(weightDbToLabel(null)).toBe('-');
    expect(weightDbToLabel(undefined)).toBe('-');
  });
});
