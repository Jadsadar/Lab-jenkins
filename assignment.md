# คู่มือปฏิบัติการ Pipeline Lab Manual: เวิร์กช็อป Jenkins CI/CD



## ภาพรวมหลักสูตรปฏิบัติการ (Overview - Ten Jenkins Laboratories)

หลักสูตรปฏิบัติการ 10 เซสชันเน้นการลงมือปฏิบัติจริงบน Jenkins ตั้งแต่การดูแล Controller, การเขียน Jenkinsfile, การเชื่อมต่อ GitHub, การตั้งเกณฑ์ทดสอบและความปลอดภัย, การจัดเตรียมโครงสร้างพื้นฐานด้วยโค้ด (IaC), การใช้งาน Dynamic Kubernetes Agents ไปจนถึงการควบคุมการทำ Deployment จริง แต่ละแล็บจะพัฒนาต่อยอดจากระบบกรณีศึกษาชื่อ **Taskflow** ซึ่งประกอบด้วย API สำหรับติดตามงานขนาดเล็ก (`taskflow-api` พัฒนาด้วย Node.js 20 / Express / PostgreSQL) และแอปพลิเคชันไคลเอนต์ Flutter (`taskflow-mobile`) ตั้งแต่แล็บที่ 10 เป็นต้นไป ผู้เรียนต้องทำการ Fork ทั้งสอง Repository เข้าบัญชี GitHub ของตนเองตั้งแต่เริ่มต้น Lab 01

* **จำนวนแล็บทั้งหมด**: 10 แล็บ


* **ระยะเวลาการเรียนรู้**: ประมาณ 34 ชั่วโมง


* **แพลตฟอร์มหลัก**: Jenkins


* **เทคโนโลยีสนับสนุน**: Docker, Kubernetes, Terraform, Prometheus



---

## ตารางแผนที่การเรียนรู้ (Lab-to-Lecture Map)

| แล็บ | ชื่อหัวข้อ | สไลด์บรรยายที่เกี่ยวข้อง | เครื่องมือหลัก | เวลา |
| --- | --- | --- | --- | --- |
| **01** | Installing Jenkins & the First Job | 04-05-Jenkins intro / install | Docker, Jenkins | 3 ชม.

 |
| **02** | Jenkins Plugins, Global Tools & RBAC | 04-05, 11 Jenkins intro / Best practices | Plugin Manager, Role Strategy | 2 ชม.

 |
| **03** | Your First Declarative Pipeline | 03, 06, 07 Stages / Jenkinsfile / Examples | Jenkinsfile, Groovy | 3 ชม.

 |
| **04** | Git, GitHub & Multibranch Pipelines | 08 Git/GitHub integration | GitHub webhooks, Jenkins | 3 ชม.

 |
| **05** | Automated Testing & Quality Gates | 09 Automated testing | Jest, Playwright, SonarQube | 4 ชม.

 |
| **06** | Shift-Left Security Pipeline | 00c, 09b DevSecOps / Security | Gitleaks, Semgrep, npm audit, Syft | 4 ชม.

 |
| **07** | Containers, Image Scanning & Deploy | 07, 09b, 10 Examples / Security / Deploy | Docker, Trivy, kubectl | 4 ชม.

 |
| **08** | Infrastructure as Code in the Pipeline | 00d-Infrastructure as Code | Terraform, Ansible, tfsec / Checkov | 4 ชม.

 |
| **09** | Jenkins on Kubernetes: Dynamic Agents & Metrics | 04, 00e Jenkins architecture / SRE | Kubernetes plugin, Prometheus, Grafana | 4 ชม.

 |
| **10** | Capstone: End-to-End Pipeline | 11-13-Best practices / Summary / Mobile | เครื่องมือทั้งหมดข้างต้น + Flutter/Gradle | 4 ชม.

 |

---

## โครงสร้างและแนวทางการใช้งานคู่มือ (How to Use This Manual)

แต่ละแล็บประกอบด้วยหัวข้อย่อยที่มีโครงสร้างเหมือนกัน ได้แก่ วัตถุประสงค์ (Objectives), ภูมิหลัง (Background), สภาพแวดล้อม (Environment), ขั้นตอนการปฏิบัติงาน (Tasks - ทำตามลำดับหมายเลข), สิ่งที่ต้องส่ง (Deliverables) และเกณฑ์การประเมินผลคะแนนเต็ม 100 คะแนน (Assessment) การทดลองออกแบบให้ใช้เวลาเซสชันละ 3–4 ชั่วโมง โดยทำเดี่ยวหรือทำคู่ตามที่ระบุ ยกเว้น Lab 10 Capstone ที่กำหนดให้ทำเป็นทีม 3–4 คน

---

## Lab 01 - Installing Jenkins & the First Job

* **สไลด์บรรยาย**: 04-05 Introduction to Jenkins / Installing Jenkins


* **ระยะเวลา**: 3 ชั่วโมง | **รูปแบบ**: งานเดี่ยว | **สิ่งที่ต้องส่ง**: ภาพถ่ายหน้าจอ + คอนเทนเนอร์ที่กำลังทำงาน



### วัตถุประสงค์

* ติดตั้ง Jenkins Controller บน Docker และตั้งค่าการใช้งานครั้งแรกให้เสร็จสมบูรณ์


* อธิบายสถาปัตยกรรม Controller / Agent / Executor และกำหนดค่า Agent ตัวที่สอง


* สร้างและเรียกทำงาน Freestyle Job เพื่อ Checkout ซอร์สโค้ด `taskflow-api`


### ภูมิหลัง

Jenkins แยก Controller (ทำหน้าที่จัดการคิวงานและแสดง UI) ออกจาก Agents (ทำหน้าที่ประมวลผลสเต็ปการบิลด์) เพื่อป้องกันไม่ให้การบิลด์หนักๆ รบกวนการทำงานของ Controller

### สภาพแวดล้อม

* Docker Desktop หรือ Docker Engine พร้อมหน่วยความจำว่างอย่างน้อย 2 GB


* บัญชี GitHub ที่ Fork คลัง `taskflow-api` เรียบร้อยแล้ว



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. ทำการ Fork `taskflow-api` และ `taskflow-mobile` เข้าสู่บัญชี GitHub ส่วนตัว (ตั้งเป็น Public หรือเพิ่ม Deploy Key ที่ Jenkins อ่านได้)


2. รัน Jenkins Controller:



```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk21

```

3. ดึงรหัสผ่านผู้ดูแลระบบเริ่มต้นและตั้งค่าระบบพร้อมชุดปลั๊กอินมาตรฐาน:



```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

```

4. ไปที่ Manage Jenkins → Nodes แล้วเพิ่ม Permanent Agent ตัวที่สอง กำหนดเลเบลเป็น `linux-build` (ใช้อิมเมจ `jenkins/inbound-agent`) ตรวจสอบให้แน่ใจว่าเชื่อมต่อสำเร็จและแสดง 1 executor


5. สร้างโปรเจกต์ Freestyle ชื่อ `taskflow-smoke` ทำการ Checkout โค้ดที่ Fork ไว้, สั่งรัน `npm ci` และแสดงเวอร์ชันของ Node กำหนดให้รันบนเลเบล `linux-build`

6. สั่งบิลด์แบบ Manual และตรวจสอบว่าสถานะผ่าน (สีเขียว) จากนั้นเปิด Console Log ตรวจสอบชื่อ Agent ที่ประมวลผล



### สิ่งที่ต้องส่ง (Deliverables)

* ภาพหน้าจอหน้า Manage Jenkins → Nodes แสดงสถานะออนไลน์ของทั้ง built-in และ linux-build agent


* Console Output ของบิลด์ `taskflow-smoke` ที่ผ่านสำเร็จ (สีเขียว)


* คำอธิบาย 1 ย่อหน้าเกี่ยวกับผลกระทบต่อบิลด์ที่กำลังทำงาน หากคอนเทนเนอร์ Controller ถูกรีสตาร์ตระหว่างการบิลด์



### เกณฑ์การประเมิน (Assessment)

* Jenkins เข้าใช้งานได้และมี 2 โหนดทำงานปกติ: 35 คะแนน


* Freestyle Job บิลด์ผ่านบน Agent ที่ระบุเลเบล: 35 คะแนน


* คำอธิบายพฤติกรรม Controller/Agent ทำงานผิดพลาดได้ถูกต้อง: 30 คะแนน



---

## Lab 02 - Jenkins Plugins, Global Tools & RBAC

* **สไลด์บรรยาย**: 04-05, 11 Introduction to Jenkins / Best Practices


* **ระยะเวลา**: 2 ชั่วโมง | **รูปแบบ**: งานเดี่ยว | **สิ่งที่ต้องส่ง**: ตารางสิทธิ์ (Roles matrix) + ไฟล์บีบอัดสำรองข้อมูล



### วัตถุประสงค์

* ติดตั้งและตั้งค่าชุดปลั๊กอินที่จำเป็นสำหรับไปป์ไลน์จริงนอกเหนือจากค่าเริ่มต้น


* กำหนดค่า Global Tool auto-installers เพื่อไม่ให้ Jenkinsfile ยึดติดกับสภาพแวดล้อมเฉพาะของ Agent


* เปลี่ยนระบบความปลอดภัยเริ่มต้นเป็น Least-Privilege Role-Based Access Control (RBAC)



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. ไปที่ Manage Jenkins → Plugins และติดตั้ง: Docker Pipeline, Blue Ocean, SonarQube Scanner, Kubernetes, Credentials Binding และ Slack Notification


2. ใน Global Tool Configuration เพิ่มตัวติดตั้งอัตโนมัติสำหรับ NodeJS (`node20`) และ JDK (`temurin-21`) จากนั้นทดสอบเรียกใช้บล็อก `tools { nodejs 'node20' }` ใน Jenkinsfile ตัวอย่าง


3. ติดตั้งปลั๊กอิน Role-based Authorization Strategy, ปิดการเข้าถึงของ Anonymous แล้วสร้าง 2 บทบาท ได้แก่ `developer` (สิทธิ์ Build และ Read บนจ็อบที่ชื่อตรงกับ `taskflow-.*`) และ `admin` (สิทธิ์เต็ม) พร้อมผูกสิทธิ์บัญชีตนเองเป็น admin และเพื่อนร่วมชั้นเป็น developer


4. สร้าง Credential ชนิด Secret text ระดับ Folder จากนั้นเข้าสู่ระบบด้วยบัญชี developer และตรวจสอบว่า UI อนุญาตให้อ้างอิง Credential ID ได้ แต่ไม่แสดงค่าความลับ


5. เปิด Blue Ocean และสั่งรันจ็อบ `taskflow-smoke` เพื่อตรวจสอบแผนภาพขั้นตอนการทำงาน


6. สำรองข้อมูล `JENKINS_HOME` ด้วยคำสั่ง:



```bash
docker run --rm --volumes-from jenkins \
  -v $(pwd):/backup alpine \
  tar czf /backup/jenkins_home.tgz /var/jenkins_home

```

เขียนขั้นตอนการกู้คืน 3 บรรทัดและทดสอบกู้คืนลงบนคอนเทนเนอร์ Jenkins ตัวใหม่

### สิ่งที่ต้องส่ง (Deliverables)

* ภาพหน้าจอรายการปลั๊กอินที่ติดตั้งและการตั้งค่า Global Tool auto-installers ทั้ง 2 ตัว


* ภาพหน้าจอ Roles Matrix และหลักฐานยืนยันว่าบัญชี developer มองไม่เห็นค่า Credential


* ไฟล์ `jenkins_home.tgz` พร้อมคู่มือขั้นตอนการ Restore ที่ผ่านการทดสอบบนคอนเทนเนอร์ตัวที่สอง



### เกณฑ์การประเมิน (Assessment)

* ปลั๊กอินครบถ้วนและ Tool Auto-installers ใช้งานได้: 25 คะแนน


* RBAC จำกัดสิทธิ์ developer ถูกต้อง และปิด anonymous access: 30 คะแนน


* การใช้ Credential ปลอดภัย ไม่เปิดเผยค่าแก่ non-admin: 25 คะแนน


* กู้คืนข้อมูลสำรองบน Jenkins ตัวที่สองสำเร็จ: 20 คะแนน



---

## Lab 03 - Your First Declarative Pipeline

* **สไลด์บรรยาย**: 03, 06, 07 Pipeline Stages / Jenkinsfile / Examples


* **ระยะเวลา**: 3 ชั่วโมง | **รูปแบบ**: งานเดี่ยว | **สิ่งที่ต้องส่ง**: Jenkinsfile บน Repository



### วัตถุประสงค์

* เขียน Declarative Jenkinsfile ที่มีบล็อก `agent`, `environment`, `stages` และ `post` จากศูนย์


* รันการบิลด์ภายใน Docker Agent แทนการรันบนเชลล์ของ Controller


* ใช้เงื่อนไขในบล็อก `post` เพื่อตอบสนองต่อผลลัพธ์สำเร็จและล้มเหลว



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เพิ่มไฟล์ `Jenkinsfile` ที่ Root ของ `taskflow-api` โดยใช้เอเจนต์ `node:20-alpine` พร้อมสเตจ Install (`npm ci`), Lint (`npm run lint`) และ Unit Test (`npm test`)


2. เพิ่มบล็อก `environment` กำหนดค่า `APP_NAME` และ `NODE_ENV = 'test'` แล้วอ้างอิงผ่านคำสั่ง `echo`

3. ใส่ `options { timeout(time: 10, unit: 'MINUTES') }` พร้อมเขียนคอมเมนต์อธิบายเหตุผลทางเทคนิค


4. ใส่บล็อก `post`: เมื่อ `success` ให้พิมพ์ข้อความยืนยัน, เมื่อ `failure` ให้พิมพ์ชื่อสเตจที่ล้มเหลวผ่าน `${env.STAGE_NAME}`, และเมื่อ `always` ให้จัดเก็บอาร์ทิแฟกต์ `npm-debug.log*` หากมี


5. สร้างไปป์ไลน์บน Jenkins ชี้ไปยัง Jenkinsfile บน Branch `main` ผ่านตัวเลือก Pipeline script from SCM


6. จงใจแก้โค้ดแบบทดสอบให้พังเพื่อดูผลลัพธ์ของบล็อก failure แล้วแก้ไขกลับให้บิลด์ผ่านสำเร็จ



```groovy
pipeline {
    agent { docker { image 'node:20-alpine' } }
    environment {
        APP_NAME = 'taskflow-api'
        NODE_ENV = 'test'
    }
    options {
        timeout(time: 10, unit: 'MINUTES')
        // A hung npm install or test run must not hold the executor forever
    }
    stages {
        stage('Install') { steps { sh 'npm ci' } }
        stage('Lint') { steps { sh 'npm run lint' } }
        stage('Unit Test') { steps { sh 'npm test' } }
    }
    post {
        success { echo "${env.APP_NAME} passed on ${env.NODE_ENV}" }
        failure { echo "Failed at stage: ${env.STAGE_NAME}" }
        always { archiveArtifacts artifacts: 'npm-debug.log*', allowEmptyArchive: true }
    }
}

```

### สิ่งที่ต้องส่ง (Deliverables)

* Jenkinsfile ที่ผ่านการผสานลงบน Branch `main` ของ Repository ที่ Fork ไว้


* Console Logs จำนวน 2 ชุด: บิลด์ที่ล้มเหลว (สีแดง) และบิลด์ที่สำเร็จ (สีเขียว) ซึ่งแสดงข้อความจากบล็อก post ถูกต้อง



### เกณฑ์การประเมิน (Assessment)

* Jenkinsfile ทำงานบน Docker Agent ถูกต้อง: 30 คะแนน


* การใช้งานและเรียกแทนค่า Environment Variables ถูกต้อง: 15 คะแนน


* บล็อก post ทำงานตรงตามเงื่อนไขที่กำหนด: 35 คะแนน


* คำอธิบายเหตุผลของการกำหนด Timeout มีความสมเหตุสมผลทางเทคนิค: 20 คะแนน



---

## Lab 04 - Git, GitHub & Multibranch Pipelines

* **สไลด์บรรยาย**: 08 Integrating with Git & GitHub


* **ระยะเวลา**: 3 ชั่วโมง | **รูปแบบ**: งานเดี่ยว | **สิ่งที่ต้องส่ง**: Webhook ที่ใช้งานได้จริง + Branch Matrix



### วัตถุประสงค์

* เชื่อมต่อ GitHub Webhook เพื่อสั่งให้ Jenkins ทำงานโดยอัตโนมัติเมื่อมีการ Push โค้ด


* กำหนดค่า Multibranch Pipeline สำหรับสแกนและค้นหา Branch และ Pull Request อัตโนมัติ


* ควบคุมสเตจ Deploy ด้วยเงื่อนไข `when { branch ... }` ให้สอดคล้องกับกลยุทธ์การแตกกิ่งจริง



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เปิดการเข้าถึง Jenkins จากอินเทอร์เน็ต (เช่น ใช้ ngrok) แล้วนำ URL ไปผูก Webhook ในการตั้งค่าของ Repository `taskflow-api` ที่อีเวนต์ push และ pull_request ชี้ไปที่ `<jenkins-url>/github-webhook/`

2. สร้าง Multibranch Pipeline บน Jenkins ให้ค้นหา Branch `main`, `develop` และ PR ที่เปิดอยู่


3. สร้าง Branch ชื่อ `develop` และ `feature/health-endpoint` จากนั้นปรับปรุง Jenkinsfile:



```groovy
stage('Deploy Staging') {
    when { branch 'develop' }
    steps { sh 'echo deploying to staging...' }
}
stage('Deploy Production') {
    when { branch 'main' }
    input { message 'Deploy to production?' }
    steps { sh 'echo deploying to production...' }
}

```

4. Push โค้ดไปยัง `feature/health-endpoint` ยืนยันว่า Webhook กระตุ้นบิลด์อัตโนมัติ และไม่มีสเตจ Deploy ใดถูกประมวลผล


5. เปิด Pull Request เข้าสู่ `develop` และยืนยันว่า Jenkins ทำการบิลด์ PR นั้นในฐานะ Job แยก


6. Merge เข้าสู่ `develop` ยืนยันว่า Deploy Staging ทำงานโดยไม่ต้องกดยืนยัน จากนั้น Merge เข้า `main` และตรวจสอบว่า Deploy Production หยุดรอการอนุมัติที่ขั้นตอน `input`


### สิ่งที่ต้องส่ง (Deliverables)

* ภาพหน้าจอประวัติการส่งข้อมูลของ GitHub Webhook แสดงสถานะตอบกลับ HTTP 200


* แผนผังกลยุทธ์ Branching ($feature \rightarrow develop \rightarrow main$) พร้อมระบุสเตจที่ทำงานในแต่ละกิ่ง



### เกณฑ์การประเมิน (Assessment)

* Webhook กระตุ้นการบิลด์ได้โดยไม่ต้องกดสั่งด้วยมือ: 25 คะแนน


* Multibranch Pipeline ค้นหา Branch และ PR ได้ถูกต้อง: 25 คะแนน


* เงื่อนไข when ควบคุมสเตจ Deploy ได้ถูกต้อง: 30 คะแนน


* ประตูตรวจสอบการอนุมัติ (Input gate) ทำงานถูกต้อง: 20 คะแนน



---

## Lab 05 - Automated Testing & Quality Gates

* **สไลด์บรรยาย**: 09 Automated Testing in Jenkins


* **ระยะเวลา**: 4 ชั่วโมง | **รูปแบบ**: งานคู่ | **สิ่งที่ต้องส่ง**: รายงาน Coverage + รายงาน Quality Gate



### วัตถุประสงค์

* เผยแพร่ผลทดสอบแบบ JUnit และรายงานความครอบคลุมรหัส (Code Coverage) แบบ Cobertura


* รันชุดทดสอบ End-to-End ด้วย Playwright ต่อระบบ `taskflow-api` ที่ทำงานบนคอนเทนเนอร์


* บังคับใช้ SonarQube Quality Gate เพื่อหยุดไปป์ไลน์หากค่าความครอบคลุมต่ำกว่าเกณฑ์



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เพิ่มคำสั่งในสเตจ Unit Test ให้รัน Jest พ่วง Reporters `jest-junit` และในบล็อก `post.always` ให้เรียกใช้ `junit` และ `publishCoverage` สำหรับ Cobertura


2. ติดตั้ง SonarQube ในเครื่องด้วยคำสั่ง `docker run -d -p 9000:9000 sonarqube:lts-community` จากนั้นสร้าง Project Token และบันทึกเป็น Credential ชนิด Secret text ชื่อ `sonar-token` บน Jenkins


3. เพิ่มสเตจวิเคราะห์ SonarQube และ Quality Gate:



```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'sonar-scanner -Dsonar.projectKey=taskflow-api'
        }
    }
}
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}

```

4. ใน SonarQube ตั้งค่าเงื่อนไขให้ Quality Gate ไม่ผ่านหาก Coverage ต่ำกว่า 70% จากนั้นจงใจลบแบบทดสอบออกเพื่อให้ Coverage ต่ำกว่าเกณฑ์ และตรวจดูว่าไปป์ไลน์หยุดทำงานที่ขั้นตอน Quality Gate


5. เพิ่มสเตจ E2E โดยใช้ Docker Agent `[mcr.microsoft.com/playwright](https://mcr.microsoft.com/playwright)` สั่งเริ่มระบบด้วย `docker compose up -d` และรันแบบทดสอบ Playwright อย่างน้อย 3 รายการ (แสดงรายการงาน, สร้างงาน, ทำเครื่องหมายว่าเสร็จสิ้น) พร้อมบันทึกรายงานผล


6. กู้คืนชุดทดสอบให้ครอบคลุมเต็มที่ รันไปป์ไลน์ใหม่ และยืนยันว่าเกณฑ์ทั้ง 3 ผ่านเป็นสีเขียวทั้งหมด



### สิ่งที่ต้องส่ง (Deliverables)

* กราฟแนวโน้มผลการทดสอบบน Jenkins แสดงประวัติอย่างน้อย 2 บิลด์ (บิลด์ที่ตกที่ Quality Gate และบิลด์ที่ผ่าน)


* รายงาน SonarQube Quality Gate ที่ผ่านการส่งออก (PDF หรือภาพหน้าจอ)


* รายงาน HTML ของ Playwright ที่ถูกจัดเก็บเป็น Artifact บน Jenkins



### เกณฑ์การประเมิน (Assessment)

* การรายงาน JUnit และ Coverage แสดงผลและมีกราฟแนวโน้มถูกต้อง: 25 คะแนน


* Quality Gate สกัดกั้นการถดถอยของคุณภาพโค้ดได้จริง: 30 คะแนน


* Playwright E2E รันแบบ Headless บน CI และรายงานผลถูกต้อง: 30 คะแนน


* ไปป์ไลน์ผ่านสมบูรณ์ตั้งแต่ต้นจนจบหลังแก้ไขโค้ด: 15 คะแนน



---

## Lab 06 - Shift-Left Security Pipeline

* **สไลด์บรรยาย**: 00c, 09b DevSecOps / Security Analysis


* **ระยะเวลา**: 4 ชั่วโมง | **รูปแบบ**: งานคู่ | **สิ่งที่ต้องส่ง**: SBOM ที่มีลายเซ็นดิจิทัล + รายงานผลการสแกน



### วัตถุประสงค์

* รันการตรวจสอบ Secrets, SAST และ SCA ก่อนเข้าสู่ขั้นตอนการบิลด์ตามลำดับ


* สร้างและจัดเก็บ Software Bill of Materials (SBOM) สำหรับ Release Artifact


* ประยุกต์ใช้นโยบายแบบกำหนดเกณฑ์เตือน/บล็อก (Fail/Warn threshold)



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เพิ่มสเตจ Secrets Detection โดยใช้ Gitleaks ตรวจสอบประวัติ Git ทั้งหมด ทดลอง Commit คีย์ AWS ปลอมบน Branch ทดสอบเพื่อยืนยันว่าตรวจจับได้จริง


2. เพิ่มสเตจ SAST โดยรัน `npx eslint --plugin security src/` และเครื่องมือ Semgrep โดยกำหนดกฎ `p/owasp-top-ten` และ `p/nodejs` พร้อมจัดเก็บผลลัพธ์เป็น SARIF


3. เพิ่มสเตจ SCA โดยใช้ `npm audit` และเขียนสคริปต์ตรวจสอบ JSON เพื่อให้บิลด์ล้มเหลวเฉพาะกรณีที่มีช่องโหว่ระดับ Critical เท่านั้น:



```groovy
stage('SCA - npm audit') {
    steps {
        script {
            sh 'npm audit --audit-level=high --json > audit.json || true'
            def critical = sh(
                script: "jq '.metadata.vulnerabilities.critical' audit.json",
                returnStdout: true
            ).trim().toInteger()
            if (critical > 0) {
                error("Blocking: ${critical} critical vulnerabilities found")
            }
            echo "SCA passed with 0 critical vulnerabilities (warnings allowed)"
        }
    }
}

```

4. เพิ่มสเตจ Generate SBOM โดยใช้ Syft ส่งออก SBOM มาตรฐาน CycloneDX และลงนามดิจิทัลด้วย Cosign จากนั้นจัดเก็บทั้งไฟล์ SBOM และลายเซ็น


5. เขียนนโยบาย OPA/Rego ใน `policy/security.rego` ปฏิเสธการบิลด์หากมีการตรวจพบช่องโหว่ระดับ Critical และตรวจสอบผ่านคำสั่ง `opa eval` ในขั้นตอน Policy Gate


6. จงใจดาวน์เกรดแพ็กเกจให้มีช่องโหว่ CVE เพื่อยืนยันว่า Policy Gate บล็อกไปป์ไลน์ได้จริง จากนั้นอัปเกรดกลับคืนเพื่อให้ไปป์ไลน์ทำงานผ่าน



### สิ่งที่ต้องส่ง (Deliverables)

* รายงาน Gitleaks ที่ตรวจจับคีย์ทดสอบได้


* ไฟล์ SBOM ที่ลงนามแล้ว (`.cdx.json` + ไฟล์ Signature)


* ไฟล์ `policy/security.rego` และบันทึก Console Log แสดงกรณีที่โดนบล็อกและกรณีที่ผ่าน



### เกณฑ์การประเมิน (Assessment)

* ลำดับสเตจความปลอดภัยถูกต้อง (Secrets → SAST → SCA → SBOM policy): 25 คะแนน


* ตรรกะ Fail/Warn ทำงานถูกต้อง ไม่ใช่แค่การดัก Exit Code 0: 25 คะแนน


* การสร้าง, ลงนาม และจัดเก็บ SBOM เสร็จสมบูรณ์: 25 คะแนน


* Policy Gate บล็อกและปล่อยผ่านบิลด์ได้ถูกต้องตามเงื่อนไข: 25 คะแนน



---

## Lab 07 - Containers, Image Scanning & Deployment

* **สไลด์บรรยาย**: 07, 09b, 10 Jenkinsfile Examples / Security / Deploying


* **ระยะเวลา**: 4 ชั่วโมง | **รูปแบบ**: งานคู่ | **สิ่งที่ต้องส่ง**: เซอร์วิสแบบ Blue/Green ที่กำลังทำงาน



### วัตถุประสงค์

* บิลด์และ Push อิมเมจ Docker พร้อมกำหนด Tag เป็นเวอร์ชันเฉพาะ โดยไม่ใช้ Tag `latest`

* สแกนอิมเมจด้วย Trivy และบล็อกการทำงานหากพบช่องโหว่ระดับ High หรือ Critical


* ติดตั้งระบบ Blue/Green Deployment บนคลัสเตอร์ Kubernetes ภายในเครื่อง (kind หรือ minikube)



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เพิ่มสเตจ Build Image กำหนดแท็กเป็น `taskflow-api:${env.GIT_COMMIT.take(7)}` (ห้ามใช้ `latest`) แล้ว Push ไปยัง Local Registry


2. เพิ่มสเตจ Container Scan ใช้ Trivy ตรวจสอบความปลอดภัยด้วยพารามิเตอร์ `--exit-code 1 --severity HIGH,CRITICAL` และจัดเก็บรายงาน SARIF


3. สร้างคลัสเตอร์ Kubernetes ในเครื่องด้วย `kind create cluster` พร้อมติดตั้ง Deployment 2 ตัว (`taskflow-blue` และ `taskflow-green`) และ Service 1 ตัวที่สลับการส่งทราฟฟิกด้วย Label Selector


4. เขียนสเตจ Blue/Green Deploy:



```groovy
stage('Blue/Green Deploy') {
    steps {
        script {
            def current = sh(
                script: "kubectl get svc taskflow -o jsonpath='{.spec.selector.color}'",
                returnStdout: true
            ).trim()
            def next = current == 'blue' ? 'green' : 'blue'

            sh "kubectl set image deployment/taskflow-${next} app=taskflow-api:${env.GIT_COMMIT.take(7)}"
            sh "kubectl rollout status deployment/taskflow-${next}"

            // smoke test the new pods directly, bypassing the Service
            sh "kubectl run smoke-${BUILD_NUMBER} --rm -i --restart=Never --image=curlimages/curl -- \
                curl -sf http://taskflow-${next}:8080/health"

            sh "kubectl patch svc taskflow -p '{\"spec\":{\"selector\":{\"color\":\"${next}\"}}}'"
            echo "Switched traffic from ${current} to ${next}"
        }
    }
}

```

5. เพิ่มบล็อก `post.failure` สั่ง Rollback อัตโนมัติด้วยการ Patch Service Selector ให้กลับไปชี้ที่สีก่อนหน้า


6. สาธิตการทำงาน 2 รอบ: รอบที่ผ่านการ Smoke Test และสลับทราฟฟิกสำเร็จ และรอบที่จงใจส่งอิมเมจมีปัญหาเพื่อแสดงการ Rollback อัตโนมัติ



### สิ่งที่ต้องส่ง (Deliverables)

* ผลลัพธ์คำสั่ง `kubectl get svc taskflow -o yaml` ทั้งก่อนและหลังสลับการทำงานสำเร็จ


* รายงาน Trivy ในรูปแบบ SARIF ของอิมเมจที่บิลด์


* Console Log ของการ Deploy ที่ล้มเหลว แสดงการทำงานของคำสั่ง Rollback อัตโนมัติ



### เกณฑ์การประเมิน (Assessment)

* การกำหนดแท็กอิมเมจแบบ Immutable และการ Push ถูกต้อง: 20 คะแนน


* Trivy สกัดกั้นอิมเมจที่มีช่องโหว่ความปลอดภัยได้จริง: 25 คะแนน


* การสลับระบบ Blue/Green ใช้งานได้และผ่าน Smoke Test ก่อนสลับ: 30 คะแนน


* แสดงการ Rollback อัตโนมัติเมื่อเกิดข้อผิดพลาดได้จริง: 25 คะแนน



---

## Lab 08 - Infrastructure as Code in the Pipeline

* **สไลด์บรรยาย**: 00d Infrastructure as Code


* **ระยะเวลา**: 4 ชั่วโมง | **รูปแบบ**: งานคู่ | **สิ่งที่ต้องส่ง**: State ของ Terraform ที่ Apply แล้ว



### วัตถุประสงค์

* เขียน Terraform สร้างสภาพแวดล้อมสำหรับ Deploy `taskflow-api` โดยใช้ Remote State


* ตรวจสอบโค้ด IaC (Lint) และสแกนความปลอดภัยก่อนคำสั่ง Plan พร้อมกั้นคำสั่ง Apply ด้วยการอนุมัติของมนุษย์


* ใช้ Ansible กำหนดค่าเซิร์ฟเวอร์หลังจากการจัดเตรียมของ Terraform



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. เขียนโค้ด Terraform สำหรับสร้าง Compute Instance, Security Group เปิดพอร์ต 8080 และแสดงผลที่อยู่ IP โดยเก็บ Remote State ไว้บนระบบที่รองรับ S3 หรือ LocalStack (ห้าม Commit ไฟล์ `terraform.tfstate`)


2. เพิ่มสเตจ IaC Lint & Validate รันคำสั่งตรวจสอบแบบขนาน:



```groovy
stage('IaC Lint & Validate') {
    parallel {
        stage('Terraform Validate') {
            steps {
                dir('infra/terraform') {
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                    sh 'terraform fmt -check -recursive'
                }
            }
        }
        stage('Ansible Lint') {
            steps { sh 'ansible-lint infra/ansible/playbook.yml' }
        }
    }
}

```

3. เพิ่มสเตจ IaC Security Scan ใช้ `tfsec` และ `checkov` สแกนไดเรกทอรี Terraform และแก้ไขข้อบกพร่องจริงที่ตรวจพบอย่างน้อย 1 รายการ


4. เพิ่มสเตจ Terraform Plan ที่จัดเก็บไฟล์ Plan และสเตจ Approval เพื่อตรวจสอบเนื้อหา Plan ก่อนรัน Terraform Apply


5. เขียน Ansible Playbook ติดตั้ง Node.js, Docker และดึงอิมเมจ `taskflow-api` จากนั้นสร้าง Dynamic Inventory จาก Output ของ Terraform เพื่อสั่งรัน Playbook


6. สั่งทำลายสภาพแวดล้อมด้วยคำสั่ง `terraform destroy` เมื่อจบการทดลองและตรวจสอบว่าไม่มีรีซอร์สค้างใน State



### สิ่งที่ต้องส่ง (Deliverables)

* ไฟล์ซอร์สโค้ด Terraform และ Ansible พร้อม Artifact ไฟล์ `tfplan` บน Jenkins


* ผลการสแกน tfsec หรือ Checkov ทั้งก่อนและหลังแก้ไขช่องโหว่


* ภาพหน้าจอขั้นตอนการกดยืนยัน (Approval Prompt) และผลลัพธ์หลัง Apply แสดงที่อยู่ของ Instance



### เกณฑ์การประเมิน (Assessment)

* ตั้งค่า Remote State ถูกต้อง ไม่มีการ Commit State ลง Git: 20 คะแนน


* แก้ไขข้อตรวจพบจาก tfsec/Checkov ได้จริง: 25 คะแนน


* ขั้นตอน Apply ถูกควบคุมด้วยขั้นตอนการอนุมัติของมนุษย์: 20 คะแนน


* Ansible Playbook ติดตั้งและตั้งค่า Host สำเร็จ: 25 คะแนน


* สั่งทำลายสภาพแวดล้อมได้อย่างสมบูรณ์ ไม่เหลือสิ่งตกค้าง: 10 คะแนน



---

## Lab 09 - Jenkins on Kubernetes: Dynamic Agents & Pipeline Metrics

* **สไลด์บรรยาย**: 04, 00e Jenkins Architecture / Site Reliability Engineering


* **ระยะเวลา**: 4 ชั่วโมง | **รูปแบบ**: งานคู่ | **สิ่งที่ต้องส่ง**: Dashboard + แจ้งเตือน Alert ที่ถูกยิง



### วัตถุประสงค์

* ใช้งาน Jenkins Build Agent ในรูปแบบ Pod ชั่วคราว (Ephemeral Pods) บน Kubernetes


* ส่งออกตัวชี้วัดการบิลด์และคิวงานของ Jenkins ไปยัง Prometheus และแสดงผลกราฟผ่าน Grafana


* กำหนด Service Level Objective (SLO) สำหรับไปป์ไลน์ และสร้างการแจ้งเตือนเมื่อระบบมีปัญหา



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. ติดตั้งปลั๊กอิน Kubernetes บน Jenkins เชื่อมต่อกับคลัสเตอร์ `kind` และสร้าง Pod Template กำหนดอิมเมจ `node:20-alpine` เลเบล `k8s-node`

2. ปรับปรุงบล็อก `agent` ของ `taskflow-api` ให้ใช้งาน Kubernetes Pod แทน Static Docker Container:



```groovy
agent {
    kubernetes {
        yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: node:20-alpine
    command: ['cat']
    tty: true
'''
    }
}

```

สั่งบิลด์และใช้คำสั่ง `kubectl get pods -w` เฝ้าดูการเกิดขึ้นและสิ้นสุดลงของ Pod ประมวลผล
3. ติดตั้งปลั๊กอิน Prometheus Metrics บน Jenkins และตรวจสอบข้อมูลตัวชี้วัดที่ `<jenkins-url>/prometheus`
4. กำหนดให้ Prometheus ดึงข้อมูลจาก Jenkins และสร้างแดชบอร์ดบน Grafana ประกอบด้วย 3 พาเนล: Build Success Rate, p95 Build Duration และ Current Queue Length
5. กำหนด SLO ของไปป์ไลน์: 95% ของการบิลด์ต้องเสร็จสิ้นภายใน 6 นาที (ประเมินย้อนหลัง 7 วัน) และเขียนกฎ Alert เมื่อคิวรอนานเกิน 2 นาทีต่อเนื่องกัน 5 นาที:

```yaml
groups:
- name: jenkins-slo
  rules:
  - alert: JenkinsQueueBacklog
    expr: jenkins_queue_size_value > 0 and avg_over_time(jenkins_queue_size_value[5m]) > 0
    for: 5m
    labels: { severity: warning }
    annotations:
      summary: "Jenkins build queue backlog exceeds 2 minutes"

```

6. จงใจสร้างภาระงานหนัก (Saturate) ด้วยการกระตุ้น 10 บิลด์พร้อมกันบนระบบที่จำกัดไว้เพียง 2 พ็อด เพื่อให้ระบบส่ง Alert จากนั้นขยายขีดความสามารถและยืนยันว่าระบบกู้คืนสู่สภาวะปกติ



### สิ่งที่ต้องส่ง (Deliverables)

* Git Diff ของ Jenkinsfile ที่เปลี่ยนจาก Docker Agent เป็น Kubernetes Pod Template


* ไฟล์ JSON แดชบอร์ด Grafana ทั้ง 3 พาเนล


* ภาพหน้าจอการแจ้งเตือนทำงานเมื่อโหลดเกิน และภาพหน้าจอสถานะกลับมาปกติหลังปรับขยายระบบ



### เกณฑ์การประเมิน (Assessment)

* การบิลด์ทำงานบน Ephemeral Kubernetes Pod ได้จริง: 30 คะแนน


* ตัวชี้วัดของ Jenkins ถูกดึงไปสร้างแดชบอร์ดถูกต้อง: 25 คะแนน


* กฎ SLO และ Alert อิงตามอาการปัญหาและถูกต้องตามหลักเทคนิค: 20 คะแนน


* สาธิตสภาวะโหลดเกินและการฟื้นฟูระบบได้สำเร็จ: 25 คะแนน



---

## Lab 10 - Capstone: End-to-End Pipeline

* **สไลด์บรรยาย**: 11-13 Best Practices / Summary / Dart-Android Pipeline


* **ระยะเวลา**: 4 ชั่วโมง + งานนอกเวลา | **รูปแบบ**: ทีม 3-4 คน | **สิ่งที่ต้องส่ง**: ไปป์ไลน์แบบครบวงจรชุดเดียว พร้อมการเดโมสด



### วัตถุประสงค์

* รวบรวมสเตจทั้งหมดจาก Lab 03–09 เข้ามาอยู่ใน Jenkinsfile เดียวที่มีการทำงานแบบคู่ขนานและเป็นระเบียบ


* ขยายไปป์ไลน์ให้ครอบคลุมการบิลด์และลงนามดิจิทัลแอปพลิเคชัน Flutter (`taskflow-mobile`)


* นำเสนอเดโมสดด้วยการเปลี่ยนแปลงโค้ดจริง และอธิบายการทำงานของแต่ละเกณฑ์ตรวจสอบ



### ขั้นตอนการปฏิบัติงาน (Tasks)

1. ปรับโครงสร้าง Jenkinsfile ของ `taskflow-api` ให้สเตจที่ไม่ขึ้นต่อกันทำงานแบบขนาน (Lint, Unit Tests, SAST, SCA) และสเตจที่ขึ้นต่อกันทำงานตามลำดับ (Build → Scan → Deploy)


2. จัดการข้อมูลความลับทั้งหมดผ่าน `withCredentials` หรือ `credentials()` โดยต้องไม่มีค่า Password หรือ Token ฝังอยู่ใน Jenkinsfile


3. สร้าง Jenkinsfile สำหรับ `taskflow-mobile` โดยใช้อิมเมจ `cirruslabs/flutter:stable` ประกอบด้วยสเตจ `flutter analyze`, `flutter test --coverage`, ตรวจสอบช่องโหว่ด้วย `osv-scanner`, บิลด์ Debug APK ในทุก Branch และบิลด์ Release AAB พร้อมลงนามผ่าน Keystore เฉพาะ Branch `main`

4. ย้ายขั้นตอนการบิลด์และทดสอบของทั้งสองโปรเจกต์ไปรันบน Kubernetes Dynamic Agents ทั้งหมด พร้อมเพิ่มสเตจ Pipeline Health Gate ก่อน Deploy Production ซึ่งจะตรวจสอบความสำเร็จของบิลด์ 20 ครั้งล่าสุดจาก Prometheus (ต้องไม่ต่ำกว่า 90%)


5. เพิ่มการแจ้งเตือนผลลัพธ์ผ่าน Slack หรืออีเมล พร้อมระบุชื่อ Branch และ URL ของบิลด์


6. จัดทำแผนภาพสถาปัตยกรรมของไปป์ไลน์แบบ 1 หน้ากระดาษ พร้อมคู่มือแก้ไขปัญหา (Rollback Runbook) สำหรับกรณีที่ขั้นตอนการ Deploy บน Production ล้มเหลว


7. นำเสนอเดโมสดความยาว 10 นาที โดย Push การแก้ไขโค้ดจริง และสาธิตกรณีที่มีเกณฑ์ความปลอดภัยหรือการทดสอบบล็อกโค้ดที่ไม่สมบูรณ์



### สิ่งที่ต้องส่ง (Deliverables)

* ไฟล์ Jenkinsfile ของทั้งฝั่ง API และ Mobile ที่ Merge แล้วและบิลด์ผ่านสมบูรณ์


* แผนภาพสถาปัตยกรรมและคู่มือ Rollback Runbook (PDF หรือเอกสาร 1 หน้า)


* วิดีโอบันทึกหรือการนำเสนอสด 10 นาที แสดงกรณีที่เกณฑ์ความปลอดภัยบล็อกโค้ดที่มีปัญหา



### เกณฑ์การประเมิน (Assessment)

* รวบรวมเกณฑ์ของทุกแล็บได้ถูกต้อง จัดลำดับเหมาะสมและรันแบบขนาน: 30 คะแนน


* ไม่มีการฮาร์ดโค้ด Credential ใน Jenkinsfile ทุกไฟล์: 15 คะแนน


* ไปป์ไลน์ฝั่ง Mobile บิลด์และลงนามดิจิทัลถูกต้อง: 20 คะแนน


* Pipeline Health Gate ทำการสกัดกั้นการ Deploy เมื่อระบบไม่เสถียรได้จริง: 15 คะแนน


* คู่มือ Runbook มีความชัดเจน ปฏิบัติตามได้จริง ไม่คลุมเครือ: 10 คะแนน


* การนำเสนอสดมีความชัดเจนและสอดคล้องกับพฤติกรรมจริงของไปป์ไลน์: 10 คะแนน