# Rollback Runbook: Deploy Production ล้มเหลว

ใช้เมื่อสเตจ **Deploy Production** ของ job `taskflow-api-multibranch/main` ล้มเหลว หรือ deploy ผ่านแล้วแต่ production มีปัญหา

## ต้องรู้ก่อนเริ่ม

- production คือ cluster kind ชื่อ `taskflow` (context `kind-taskflow`) namespace `default`
- มี Deployment 2 ชุด คือ `taskflow-blue` และ `taskflow-green` Service `taskflow` ส่ง traffic ไปที่สีเดียวตาม `selector.color`
- ทุกบิลด์ deploy ลงสีที่ว่างอยู่ แล้วค่อยสลับ Service ไป **สีเดิมยังรันเวอร์ชันก่อนหน้าอยู่เสมอ** การ rollback จึงแค่สลับ Service กลับ
- image ทุกตัวติด tag เป็น commit SHA 7 ตัว เช่น `localhost:5001/taskflow-api:be86e73` ไม่มี tag `latest`
- รันทุกคำสั่งจากเครื่องที่รัน Docker Desktop ใส่ `--context kind-taskflow` ทุกครั้ง

## ขั้นที่ 1: ดูว่าเกิดอะไรขึ้น (2 นาที)

1. เปิด Console Output ของบิลด์ที่ล้มเหลว แล้วหาบรรทัดท้ายสเตจ Deploy Production

   | เห็นบรรทัดนี้ | แปลว่า | ไปขั้นที่ |
   |---|---|---|
   | `ROLLBACK: traffic restored to <สี>` | ระบบ rollback อัตโนมัติแล้ว | 2 |
   | ไม่มีบรรทัด ROLLBACK หรือ Jenkins ล่มระหว่าง deploy | ต้อง rollback เอง | 3 |
   | deploy ผ่าน (`Switched traffic from X to Y`) แต่ผู้ใช้แจ้งว่ามีปัญหา | ต้อง rollback เอง | 3 |

2. ดูสถานะปัจจุบัน
   ```powershell
   kubectl --context kind-taskflow get svc taskflow -o jsonpath="{.spec.selector.color}"
   kubectl --context kind-taskflow get deploy taskflow-blue taskflow-green -o wide
   ```
   บรรทัดแรกคือสีที่รับ traffic อยู่ คอลัมน์ `IMAGES` บอกว่าแต่ละสีรันเวอร์ชันไหน

## ขั้นที่ 2: ยืนยันว่า rollback อัตโนมัติได้ผล

```powershell
kubectl --context kind-taskflow run rb-check --rm -i --restart=Never --image=curlimages/curl -- curl -sf http://taskflow:8080/health
```
- ได้ `{"status":"ok","db":"connected"}` แปลว่าจบ ไปขั้นที่ 5
- ไม่ได้ผลนี้ ไปขั้นที่ 3

## ขั้นที่ 3: สลับ traffic กลับสีเดิมด้วยมือ

1. ดูสีที่ Service ชี้อยู่ตอนนี้จากขั้นที่ 1 (เรียกว่า `BAD`) อีกสีคือ `GOOD` เช่น ถ้า Service ชี้ `green` ให้ GOOD = `blue`
2. ตรวจว่าสี GOOD ยังพร้อมรับ traffic
   ```powershell
   kubectl --context kind-taskflow rollout status deployment/taskflow-blue --timeout=60s
   kubectl --context kind-taskflow run rb-good --rm -i --restart=Never --image=curlimages/curl -- curl -sf http://taskflow-blue:8080/health
   ```
   (เปลี่ยน `blue` เป็นสี GOOD) ถ้าข้อนี้ไม่ผ่าน ห้ามสลับ ให้ไปขั้นที่ 4
3. สลับ Service ไปสี GOOD
   ```powershell
   kubectl --context kind-taskflow patch svc taskflow -p '{\"spec\":{\"selector\":{\"color\":\"blue\"}}}'
   ```
4. ทำขั้นที่ 2 ซ้ำเพื่อยืนยัน

## ขั้นที่ 4: ทั้งสองสีเสีย ให้ deploy เวอร์ชันที่เคยใช้ได้กลับไป

1. ดู tag ที่มีใน registry แล้วเลือก SHA ของบิลด์ main ที่ผ่านล่าสุด (ดูจาก Build History ของ job `main` ในบิลด์ที่เป็นสีเขียว)
   ```powershell
   curl http://localhost:5001/v2/taskflow-api/tags/list
   ```
2. ใส่ image นั้นลงสีที่ไม่ได้รับ traffic แล้วรอให้พร้อม (ตัวอย่างใช้ `green` และ `be86e73`)
   ```powershell
   kubectl --context kind-taskflow set image deployment/taskflow-green app=localhost:5001/taskflow-api:be86e73
   kubectl --context kind-taskflow rollout status deployment/taskflow-green --timeout=120s
   kubectl --context kind-taskflow run rb-old --rm -i --restart=Never --image=curlimages/curl -- curl -sf http://taskflow-green:8080/health
   ```
3. ผ่านแล้วจึงสลับ Service ไปสีนั้นตามขั้นที่ 3 ข้อ 3 แล้วทำขั้นที่ 2
4. ถ้ายังไม่ผ่าน ปัญหาอาจอยู่ที่ฐานข้อมูลหรือ MinIO ไม่ใช่ตัวแอป ให้ตรวจ
   ```powershell
   kubectl --context kind-taskflow get pods
   kubectl --context kind-taskflow logs deployment/taskflow-green --tail=50
   ```

## ขั้นที่ 5: หลัง rollback

1. แจ้งทีมพร้อมลิงก์บิลด์ที่ล้มเหลว, สีและ SHA ที่กลับไปใช้
2. **ห้าม** กด Build Now ที่ `main` ซ้ำเพื่อ "ลองอีกที" แก้ต้นเหตุบน branch แยก แล้ว merge ผ่าน PR ตามปกติ
3. บิลด์ที่ล้มเหลวทำให้อัตราสำเร็จลดลง ถ้าต่ำกว่า 90% ของ 20 บิลด์ล่าสุด **Pipeline Health Gate จะบล็อก deploy ครั้งถัดไป** ตามที่ออกแบบไว้ ไม่มีทางข้าม gate ต้องให้บิลด์ที่ผ่านดันอัตรากลับขึ้นมาก่อน ดูอัตราปัจจุบันได้ที่ Grafana http://localhost:3000
4. บันทึกสาเหตุและวิธีแก้ลงใน issue ของ repo

## Checklist
- [ ] รู้ว่าสีไหนรับ traffic และแต่ละสีรัน SHA อะไร
- [ ] `/health` ของ Service `taskflow` ตอบ ok
- [ ] แจ้งทีมพร้อมลิงก์บิลด์และ SHA ที่ใช้อยู่
- [ ] เปิด issue สำหรับต้นเหตุ
