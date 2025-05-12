#include <windows.h>
#include <iostream>
#include <cstdint>

/*
Usage: 
    g++ read_sma_echo.cpp -o read_sma_echo
    ./read_sma_echo
*/
#define COM_PORT_NAME "\\\\.\\COM3"  // Update as needed
#define BAUD_RATE CBR_115200

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
    GetCommState(hSerial, &dcbSerialParams);

    dcbSerialParams.BaudRate = BAUD_RATE;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity   = NOPARITY;

    SetCommState(hSerial, &dcbSerialParams);

    COMMTIMEOUTS timeouts = { 0 };
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    SetCommTimeouts(hSerial, &timeouts);

    return hSerial;
}

int main() {
    HANDLE hSerial = open_serial_port(COM_PORT_NAME);
    uint8_t bytes[2];
    DWORD bytesRead;

    std::cout << "Listening for SMA echo from FPGA..." << std::endl;

    while (true) {
        // Read 2 bytes for SMA result
        if (!ReadFile(hSerial, &bytes[0], 1, &bytesRead, NULL) || bytesRead != 1)
            continue;

        if (!ReadFile(hSerial, &bytes[1], 1, &bytesRead, NULL) || bytesRead != 1)
            continue;

        uint16_t sma_fixed = (bytes[1] << 8) | bytes[0];  // LSB first
        float sma_value = sma_fixed / 256.0f;  // Q8.8 format

        std::cout << "SMA: " << sma_value << std::endl;
        Sleep(50);  // Optional: throttle output rate
    }

    CloseHandle(hSerial);
    return 0;
}