#include <windows.h>
#include <iostream>
#include <fstream>
#include <vector>

#define COM_PORT_NAME "\\\\.\\COM3"  // Use Device Manager to check your COM port
#define BAUD_RATE CBR_115200         // Match this with FPGA UART baud

HANDLE open_serial_port(const char* port_name) {
    HANDLE hSerial = CreateFileA(port_name,
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL);

    if (hSerial == INVALID_HANDLE_VALUE) {
        std::cerr << "Error opening COM port." << std::endl;
        exit(1);
    }

    DCB dcbSerialParams = { 0 };
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams)) {
        std::cerr << "Failed to get COM state." << std::endl;
        exit(1);
    }

    dcbSerialParams.BaudRate = BAUD_RATE;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity   = NOPARITY;

    if (!SetCommState(hSerial, &dcbSerialParams)) {
        std::cerr << "Failed to set COM state." << std::endl;
        exit(1);
    }

    COMMTIMEOUTS timeouts = { 0 };
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;

    SetCommTimeouts(hSerial, &timeouts);
    return hSerial;
}

void send_data(HANDLE hSerial, const std::vector<uint8_t>& data) {
    DWORD bytesWritten;
    if (!WriteFile(hSerial, data.data(), data.size(), &bytesWritten, NULL)) {
        std::cerr << "WriteFile failed." << std::endl;
    }
}

int main() {
    HANDLE hSerial = open_serial_port(COM_PORT_NAME);

    std::ifstream infile("data_stream.bin", std::ios::binary);
    if (!infile.is_open()) {
        std::cerr << "Failed to open data file!" << std::endl;
        return 1;
    }

    std::vector<uint8_t> buffer(128);  // Chunk size = 128 bytes
    while (infile.read(reinterpret_cast<char*>(buffer.data()), buffer.size()) || infile.gcount() > 0) {
        send_data(hSerial, buffer);
        Sleep(1);  // Sleep to avoid overfilling FPGA UART buffer
    }

    std::cout << "Finished sending data to FPGA." << std::endl;
    CloseHandle(hSerial);
    return 0;

}