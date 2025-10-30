# פוסט לינקדין - הפרויקט הראשון שלי 🎓

---

## גרסה 1 - בעברית (פשוטה)

עובד על הפרויקט הראשון שלי בעיצוב חומרה דיגיטלית! 🚀

בתור סטודנט שרק מתחיל את הדרך ב-RTL, החלטתי ללמוד באופן מעשי ולבנות מעבד RISC-V single-cycle מאפס.

**איך הלכתי על זה:**

💻 **התחלתי מהבסיס** - לפני שבניתי את המעבד, למדתי איך לעשות כל רכיב בנפרד:
- Program Counter - איך המעבד יודע איפה הוא בקוד
- Register File - איך מאחסנים ומנהלים 32 רגיסטרים
- ALU - "המחשבון" שעושה את כל החישובים (חיבור, חיסור, shifts, AND, OR...)
- Memory - זיכרון עם byte-enable וקריאה/כתיבה
- Decoder - פענוח ההוראות ל-control signals

📚 **חיבור הכל ביחד** - אחרי שכל רכיב עבד לבד, חיברתי הכל למעבד single-cycle שמריץ הוראות RISC-V:
- הוראות אריתמטיות (ADD, SUB, SLT, shifts...)
- הוראות לוגיות (AND, OR, XOR...)
- Load/Store (LB, LH, LW, SB, SH, SW) עם sign extension
- Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)

⚙️ **זה עובד!** - המעבד יכול להריץ תוכניות assembly שכתבתי, וגם קוד C שמתקמפל עם RISC-V toolchain. יש לי testbench שבודק הכל ומדפיס טבלאות יפות של כל הוראה שרצה.

🛠️ **הכלים שלמדתי:**
- SystemVerilog - השפה לעיצוב חומרה
- Icarus Verilog - לסימולציה
- GTKWave - לראות איך הסיגנלים משתנים בזמן
- RISC-V GCC toolchain - לקמפל C ל-machine code

🎯 **מה למדתי:**
- איך מעבד באמת עובד ברמת החומרה
- איך להבין את instruction encoding של RISC-V
- איך לכתוב testbench טוב שבודק הכל
- debugging חומרה זה לגמרי שונה מ-software!

עדיין בתהליך ויש עוד הרבה מה לשפר ולהוסיף, אבל כבר למדתי המון! 💪

הפרויקט זמין ב-GitHub אם מישהו רוצה להסתכל או ללמוד ממנו 😊

#Hardware #RTL #RISCV #SystemVerilog #DigitalDesign #Learning #FirstProject #StudentLife

---

## גרסה 2 - אנגלית

Working on my first hardware design project! 🚀

As a student taking my first steps in RTL design, I decided to learn by doing and build a RISC-V single-cycle CPU from scratch.

**How I approached it:**

💻 **Started with the basics** - Before building the CPU, I learned how to create each component separately:
- Program Counter - how the CPU tracks its position in code
- Register File - managing 32 registers for data storage
- ALU - the "calculator" that does all computations (add, sub, shifts, AND, OR...)
- Memory - implementing byte-enable, read/write operations
- Decoder - decoding instructions into control signals

📚 **Connecting it all** - After each component worked individually, I connected everything into a single-cycle processor that executes RISC-V instructions:
- Arithmetic instructions (ADD, SUB, SLT, shifts...)
- Logical operations (AND, OR, XOR...)
- Load/Store (LB, LH, LW, SB, SH, SW) with sign extension
- Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)

⚙️ **It works!** - The CPU can run assembly programs I wrote, and even C code compiled with the RISC-V toolchain. I have a testbench that verifies everything and prints nice tables of each executed instruction.

🛠️ **Tools I learned:**
- SystemVerilog - the hardware design language
- Icarus Verilog - for simulation
- GTKWave - to visualize signal waveforms over time
- RISC-V GCC toolchain - to compile C to machine code

🎯 **What I learned:**
- How CPUs actually work at the hardware level
- Understanding RISC-V instruction encoding
- Writing good testbenches that verify everything
- Hardware debugging is completely different from software!

Still a work in progress with lots to improve and add, but I've already learned so much! 💪

Project available on GitHub if anyone wants to check it out or learn from it 😊

#Hardware #RTL #RISCV #SystemVerilog #DigitalDesign #Learning #FirstProject #StudentLife

---

## גרסה 3 - יותר קצרה ואישית (בעברית)

עובד על הפרויקט הראשון שלי בעיצוב חומרה! 🚀

החלטתי ללמוד איך מעבד באמת עובד, אז בניתי RISC-V CPU מאפס ב-SystemVerilog.

התהליך:
- קודם בניתי כל רכיב בנפרד (ALU, Register File, Memory, Decoder...)
- אחר כך חיברתי הכל למעבד שלם
- דיבגתי המון באגים (ולמדתי שdebug בחומרה זה לגמרי שונה מsoftware!)
- עכשיו זה רץ תוכניות RISC-V 💪

הרגע הכי מגניב? כשראיתי assembly code שכתבתי רץ על החומרה שבניתי. משהו ממש שונה מלהריץ קוד על מעבד קיים.

למדתי המון על instruction encoding, control signals, איך זיכרון עובד, ועוד המון דברים שלא מבינים כשרק לומדים תיאוריה.

עדיין יש המון מה לשפר ולהוסיף, אבל זה כבר עובד וזה מרגיש טוב! 🎉

#Hardware #RTL #RISCV #SystemVerilog #Learning #StudentLife

---

## גרסה 4 - עם פרטים טכניים יותר מעמיקים (לאלו שרוצים להראות הבנה)

בניתי מעבד RISC-V single-cycle מאפס ב-SystemVerilog! 🚀

**הארכיטקטורה:**
המעבד בנוי מ-6 מודולים מרכזיים:
- **PC (Program Counter)** - מנהל את הכתובת הנוכחית עם mux בין PC+4 לבין jump/branch targets
- **Memory** - unified instruction/data memory עם byte-enable masks לכתיבה granular ו-sign extension לקריאה
- **Decoder** - פענוח של opcodes, funct3, funct7 לסט של control signals
- **Register File** - 32 רגיסטרים של 32-bit עם dual-read ports ו-x0 hardwired לאפס
- **ALU** - תומך ב-10 פעולות: ADD, SUB, SLT/SLTU, shifts (SLL/SRL/SRA), לוגיות (AND/OR/XOR)
- **Branch Condition Unit** - מחשב תנאי branches (BEQ/BNE/BLT/BGE/BLTU/BGEU)

**ההוראות שמומשו:**
✅ R-type: כל ההוראות האריתמטיות והלוגיות  
✅ I-type: ALU immediates + Load instructions (LB/LH/LW/LBU/LHU)  
✅ S-type: Store instructions (SB/SH/SW)  
✅ B-type: כל ה-branches  
⏳ עדיין לעבוד על: JAL, JALR, LUI, AUIPC

**הדברים המעניינים שלמדתי:**
- איך byte-enable masks עובדים בזיכרון (למשל, לכתוב רק byte אחד בתוך word)
- ההבדל בין signed ו-unsigned comparisons ב-hardware
- איך control signals עוברים דרך כל המעבד ומתאמים את הכל
- כתיבת testbench שקורא instruction memory ומדפיס execution trace

**כלי פיתוח:**
- SystemVerilog לעיצוב
- Icarus Verilog לסימולציה
- GTKWave לוויזואליזציה
- RISC-V GCC toolchain לקמפול C ו-assembly

זה פרויקט חי - עדיין מוסיף הוראות ומשפר דברים, אבל כבר רץ קוד אמיתי! 💪

הפרויקט פתוח ב-GitHub אם מישהו רוצה לצלול לפרטים 🔗

#Hardware #RTL #RISCV #SystemVerilog #DigitalDesign #CPUDesign #ComputerArchitecture

---

## טיפים לפרסום:

1. **תמונה:** תוסיף תמונה של הפרויקט - אפשר screenshot של:
   - הדיאגרמה של המעבד (cpu.jpg שיש לך בdocs)
   - GTKWave עם waveforms של הסיגנלים
   - הטבלה היפה שה-testbench מדפיס
   - חלק מהקוד SystemVerilog
   - או הלוגו של RISC-V

2. **איזו גרסה לבחור:**
   - **גרסה 1** - מאוזנת, מסבירה את כל התהליך בפירוט סביר
   - **גרסה 2** - באנגלית, אם אתה רוצה להגיע לקהל בינלאומי
   - **גרסה 3** - קצרה ואישית, קלה לקריאה
   - **גרסה 4** - טכנית יותר, מראה שבאמת מבין לעומק מה בניתִ

3. **תזמון:** תפרסם בזמן שאנשים בענף פעילים - בדרך כלל בוקר/צהריים באמצע השבוע (א-ה)

4. **תגיות:** ההאשטאגים חשובים להגעה - אל תשכח אותם!

5. **לינק:** תוסיף את הלינק ל-GitHub בתגובה הראשונה או בפרופיל שלך

איזה גרסה הכי מדברת אליך? אני יכול לשנות או לשפר לפי מה שאתה מרגיש! 😊

