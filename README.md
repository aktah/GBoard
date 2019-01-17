# GBoard System (0.3.7-R2 เท่านั้น)
เป็น Filterscript บอร์ดจัดอันดับหรือแสดงข้อความสำหรับเซิร์ฟเวอร์ DM ทั่วไป
![GBoard System](https://i.imgur.com/q9p8dYw.png)

# ตัวอย่าง
<a href="http://www.youtube.com/watch?feature=player_embedded&v=3WjapiflOdk
" target="_blank"><img src="http://img.youtube.com/vi/3WjapiflOdk/0.jpg" 
alt="ตัวอย่างระบบ GBoard" width="240" height="180" border="10" /></a>

# วิธีติดตั้ง 

ภาพประกอบ

![ภาพประกอบ phpMyAdmin](https://i.imgur.com/DgjA2e2.png)

- ตั้งค่าการเชื่อมต่อฐานข้อมูลที่ไฟล์ scriptfiles/mysql.ini
ข้อมูลจะถูกขั้นด้วย "|" เรียงลำดับดังนี้ ชื่อฐานข้อมูล (หมายเลข 3 ในภาพประกอบ), ชื่อโฮสต์หรืออาจใช้ localhost, ชื่อผู้ใช้, รหัสผ่าน

<ชื่อผู้ใช้ และ รหัสผ่าน เป็นตัวเดียวกับที่ใช้เข้า phpMyAdmin>

- ในไฟล์ filterscripts/GBoard.pwn กำหนดชื่อตารางและฟิลด์ข้อมูลผู้เล่นที่

PLAYER_TABLE_NAME (หมายเลข 1 ในภาพประกอบด้านบน)

PLAYER_FIELD_NAME (หมายเลข 2 ในภาพประกอบด้านบน)

![ภาพประกอบ GBoard.pwn](https://i.imgur.com/evRuS2o.png)


- Compile ไฟล์ GBoard.pwn ด้วย Pawno และ Include ที่ให้ไว้และคุณจะได้รับไฟล์สกุล .amx
- นำไฟล์ทั้งหมดไปวางไว้ในตัวเซิร์ฟเวอร์ของคุณ เพิ่ม plugins ในไฟล์ server.cfg ตัวไหนที่ยังไม่ได้เพิ่มก็ใส่เข้าไปให้ครบ (CEFix mysql sscanf streamer YSF)
- ติดตั้งไฟล์ฐานข้อมูลในโฟลเดอร์ DB/board_sys.sql
