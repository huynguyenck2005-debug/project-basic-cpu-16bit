# 16-Bit Processor Design and Implementation on FPGA

Dự án thiết kế và phát triển bộ xử lý (CPU) 16-bit, được thực hiện trong khuôn khổ môn học Kiến trúc BUS tại HCMUS. Dự án bao gồm việc thiết kế khối Data Path, khối điều khiển FSM (Control Unit), mở rộng tập lệnh, kiểm chứng bằng Assembly và hiện thực hóa phần cứng trên board FPGA DE1-SoC.

---

## 1. Kiến Trúc Bộ Xử Lý (Processor Architecture)

Bộ vi xử lý được phát triển qua 2 giai đoạn cốt lõi dựa trên tài liệu hướng dẫn Lab 9 và Lab 10:

### Giai đoạn 1: Simple Processor (Cơ bản)
- **Cấu trúc:** Gồm 8 thanh ghi chung (R0 đến R7), khối tính toán ALU và bộ ghép kênh Mux.
- **Tập lệnh cơ bản:** `mv` (Move), `mvt` (Move Top), `add` (Cộng), `sub` (Trừ).
- **Điều khiển:** Máy trạng thái FSM phân tích chu trình lệnh qua các bước thời gian từ T0 đến T3.

### Giai đoạn 2: Enhanced Processor (Cải tiến & Mở rộng)
- **Tích hợp PC:** Chuyển đổi thanh ghi `r7` đóng vai trò làm Bộ đếm chương trình (Program Counter) tự động tăng để phục vụ cơ chế nạp lệnh (Instruction Fetch).
- **Truy cập bộ nhớ:** Bổ sung các lệnh giao tiếp bộ nhớ RAM/ROM: `ld` (Load) và `st` (Store).
- **Lệnh logic & Rẽ nhánh:** Tích hợp thêm lệnh `and` và các lệnh rẽ nhánh có điều kiện/không điều kiện phục vụ vòng lặp: `b` (Branch), `bcc`, `bcs`, `bne`, `beq`.

---

## 2. Cấu Trúc Các File Trong Repository

Repository chứa toàn bộ mã nguồn mô tả phần cứng Verilog, các chương trình kiểm thử bằng hợp ngữ và báo cáo chi tiết:

- `README.md`: Tài liệu hướng dẫn tổng quan dự án (File này).
- `proc.v`: File chứa mã nguồn Verilog cốt lõi mô tả kiến trúc bộ xử lý (Data Path và Control Unit FSM).
- `testbench files`: Các file kiểm thử (Testbench Verilog) phục vụ quá trình mô phỏng xung nhịp và kiểm tra luồng dữ liệu trên ModelSim / Quartus.
- `assembly files (*.s)`: Các chương trình viết bằng hợp ngữ (Assembly 16-bit) của CPU dùng để biên dịch thành mã máy nạp vào bộ nhớ để chạy thực tế (ví dụ: các đoạn mã kiểm thử lệnh rẽ nhánh, tính toán loop).
- `Project_BUS_CPU_16bit_FPGA.pdf`: File báo cáo đồ án hoàn chỉnh, trình bày chi tiết sơ đồ khối, phân tích chu kỳ lệnh, lưu đồ thuật toán FSM và kết quả thực nghiệm trên board DE1-SoC.

---

## 3. Quy Trình Mô Phỏng & Kiểm Chứng

1. **Mô phỏng phần cứng:**
   - Sử dụng phần mềm ModelSim để chạy các file testbench kết hợp cùng `proc.v`.
   - Quan sát dạng sóng (Waveform) tại các bước thời gian T0, T1, T2, T3 để xác nhận dữ liệu dịch chuyển chính xác giữa Bus, ALU và các thanh ghi.
2. **Kiểm thử phần mềm (Assembly):**
   - Các file chương trình `.s` được nạp vào bộ nhớ (Memory) tích hợp cùng hệ thống.
   - Kiểm tra tính đúng đắn của các lệnh điều kiện (`beq`, `bne`,...) thông qua giá trị thay đổi của thanh ghi `r7` (PC) và các thanh ghi kết quả.
3. **Triển khai FPGA:**
   - Tổng hợp mạch (Synthesis) bằng phần mềm Intel Quartus Prime, cấu hình chân và đổ mạch xuống board FPGA DE1-SoC để kiểm chứng bằng các công cụ hiển thị (LED, Hex Display, Switch).
