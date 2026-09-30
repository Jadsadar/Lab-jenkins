# สคริปต์เดโมสด 10 นาที (Lab 10 Task 7)

เดโมนี้ push โค้ดจริง 3 ครั้ง แต่ละครั้งถูก gate คนละตัวบล็อก แล้วจบด้วยบิลด์ที่ผ่านบน `main`

## เตรียมก่อนขึ้นเดโม (ทำก่อน 15 นาที)

1. เช็กว่า service ทั้งหมดรันอยู่
   ```powershell
   docker ps --format "{{.Names}}: {{.Status}}" | Select-String "jenkins|sonarqube|prometheus|grafana|mailpit|taskflow-control-plane|kind-registry"
   ```
2. เปิด ngrok แล้วอัปเดต Payload URL ของ webhook ใน GitHub ให้ตรงกับ URL ใหม่
   ```powershell
   ngrok http 8080
   ```
3. เปิดแท็บเบราว์เซอร์ไว้ล่วงหน้า

   | แท็บ | URL |
   |---|---|
   | Jenkins (Blue Ocean) | http://localhost:8080/blue/organizations/jenkins/taskflow-api-multibranch/branches |
   | Mailpit (อีเมลแจ้งเตือน) | http://localhost:8025 |
   | Grafana | http://localhost:3000 |
   | GitHub repo | https://github.com/Jadsadar/Lab-jenkins |
4. ใช้ branch `main` ล่าสุดเป็นจุดเริ่ม
   ```powershell
   git checkout main
   git pull
   ```

## ลำดับเดโม

| เวลา | ทำอะไร | สิ่งที่ผู้ชมควรเห็น |
|---|---|---|
| 0:00–1:30 | เปิด [docs/ARCHITECTURE.md](ARCHITECTURE.md) บน GitHub อธิบายภาพรวม | สเตจแบบขนาน vs ตามลำดับ และ gate ทั้งหมด |
| 1:30–4:00 | **เดโม 1: เทสต์พัง** | Unit Test แดง, สเตจขนานอื่นหยุด (failFast), อีเมล FAILURE |
| 4:00–6:30 | **เดโม 2: แพ็กเกจมีช่องโหว่ critical** | SCA แดง และ Policy Gate ของ OPA ขึ้น `Blocked: ... critical` |
| 6:30–8:30 | **เดโม 3: Pipeline Health Gate** | โค้ดผ่านทุก check แต่ Health Gate บล็อกเพราะอัตราสำเร็จต่ำกว่า 90% |
| 8:30–10:00 | เปิดบิลด์ที่ผ่านของ `main` (API และ mobile) | ปุ่ม Approval, Blue/Green deploy, ไฟล์ AAB ที่ลงนามแล้ว |

### เดโม 1: เทสต์พัง (Quality gate)
```powershell
git checkout -b demo/broken-test main
# แก้ backend/api/src/pets/pet-mappers.spec.ts บรรทัดแรกของ expect ให้ผิด เช่น 'male' เป็น 'female'
git commit -am "demo: break a unit test"
git push -u origin demo/broken-test
```
พูดระหว่างรอ: webhook สั่งบิลด์ทันที ทุก check ที่ไม่ขึ้นต่อกันรันพร้อมกัน พอเทสต์พัง `failFast` หยุดตัวที่เหลือ บิลด์จึงไม่ไปถึง Build Image หรือ Deploy

### เดโม 2: ช่องโหว่ critical (Security gate)
```powershell
git checkout -b demo/vulnerable-dep main
cd backend/api
npm install minimist@0.0.8 --save-dev
cd ../..
git commit -am "demo: add minimist 0.0.8 (critical prototype pollution CVE)"
git push -u origin demo/vulnerable-dep
```
ชี้ให้ดู 2 จุด: สเตจ `SCA - npm audit` ขึ้น `Blocking: N critical vulnerabilities found` และ `Policy Gate` ขึ้น `Blocked: N critical vulnerabilities found by npm audit` เป็น 2 ด่านอิสระ ถ้าด่านหนึ่งตั้งค่าผิด อีกด่านยังบล็อกอยู่

### เดโม 3: Pipeline Health Gate
branch `demo/*` รัน Health Gate โดยใช้ประวัติขั้นต่ำ 1 บิลด์ (บน `main` ใช้ 5)
```powershell
git checkout -b demo/health-gate main
# ทำเทสต์พังแบบเดโม 1 แล้ว push: บิลด์แรกของ job นี้ล้มเหลว
git commit -am "demo: failing build lowers the success rate"
git push -u origin demo/health-gate
# รอบิลด์จบ แล้วแก้เทสต์กลับ
git revert --no-edit HEAD
git push
```
บิลด์ที่ 2 ผ่านทุก check แต่สเตจ `Pipeline Health Gate` ขึ้น
```
Health gate BLOCKED: 0/1 of the last builds succeeded = 0.0% (threshold 90%)
```
พูด: ถึงโค้ดชุดนี้จะถูก แต่ไปป์ไลน์ของ branch นี้เพิ่งล้มเหลว ระบบจึงไม่ยอม deploy จนกว่าอัตราสำเร็จจะกลับมาอย่างน้อย 90%

### ปิดเดโม
- เปิด Mailpit ให้ดูอีเมลแจ้งเตือนทุกบิลด์ ที่มีชื่อ branch และลิงก์บิลด์
- เปิดบิลด์สีเขียวของ `main`: API ที่ผ่าน Health Gate, กด Approval แล้ว deploy แบบ Blue/Green และ mobile ที่มี `app-release.aab` ใน Build Artifacts
- ลบ branch เดโมหลังจบ
  ```powershell
  git push origin --delete demo/broken-test demo/vulnerable-dep demo/health-gate
  ```

## ถ้าเดโมติดขัด
| อาการ | ทำอย่างไร |
|---|---|
| push แล้วไม่มีบิลด์ | URL ของ ngrok เปลี่ยน ให้แก้ Payload URL ของ webhook หรือกด **Scan Repository Now** |
| บิลด์ค้างที่ `Waiting for next available executor` | บิลด์อื่นใช้ `linux-build` อยู่ รอหรือ Abort บิลด์นั้น |
| ไม่มีอีเมลใน Mailpit | `docker start mailpit` |
