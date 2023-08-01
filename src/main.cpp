#include <dia2.h>
#include <atlbase.h>
#include <iostream>

using namespace std;

using DllGetClassObject_t = HRESULT(__stdcall*)(REFCLSID rclsid, REFIID riid, LPVOID* ppv);

bool process_arguments(int _argc, wchar_t* _argv[], wstring& _pdb_file) {
    bool print_symstore_id = false;

    for (int i = 1; i < _argc; ++i) {
        wstring arg = _argv[i];
        if (arg == L"-ssid" || arg == L"--symbol-store-id") {
            print_symstore_id = true;
        } else {
            _pdb_file = arg;  // Assuming the PDB file is the only non-option argument
        }
    }

    return print_symstore_id;
}

int wmain(int _argc, wchar_t* _argv[]) {
    auto pdb_file          = wstring{};
    auto print_symstore_id = process_arguments(_argc, _argv, pdb_file);
    if (pdb_file.empty()) {
        wcerr << L"Usage: " << _argv[0] << L" <pdb-file> [-ssid | --symbol-store-id]\n"
              << L"\n"
              << L"  pdb-file                   path to the PDB file\n"
              << L"  -ssid, --symbol-store-id   print a SymStore-compatible ID\n"
              << L"\n"
              << L"Remarks:\n"
              << L"  The program prints the GUID of the PDB file. If the -ssid or --symbol-store-id\n"
              << L"  option is given, it prints a SymbolStore-compatible ID instead.\n"
              << L"  If the program fails, it does not print anything and returns -1.\n";
        return -1;
    }

    auto ok            = true;
    auto get_class_obj = (DllGetClassObject_t) nullptr;
    auto factory       = (IClassFactory*)nullptr;
    auto guid          = GUID{};
    auto age           = DWORD{};
    auto msdia140      = (HMODULE) nullptr;

    auto source_interface       = CComPtr<IDiaDataSource>{};
    auto session_interface      = CComPtr<IDiaSession>{};
    auto global_scope_interface = CComPtr<IDiaSymbol>{};

    ok = ok && !FAILED(CoInitialize(nullptr));                                                                   // Initialize the COM library DIA for the calling thread
    ok = ok && (msdia140 = LoadLibrary(L"msdia140.dll")) != nullptr;                                             // Load the DIA DLL that we distributed with this software
    ok = ok && (get_class_obj = (DllGetClassObject_t)GetProcAddress(msdia140, "DllGetClassObject")) != nullptr;  // Get a pointer to the DllGetClassObject function
    ok = ok && !FAILED(get_class_obj(__uuidof(DiaSource), IID_IClassFactory, (void**)&factory));                 // Use `DllGetClassObject` to get a class factory for the `IDiaSource` class
    ok = ok && !FAILED(factory->CreateInstance(NULL, __uuidof(IDiaDataSource), (void**)&source_interface));      // Create the data source
    ok = ok && !FAILED(source_interface->loadDataFromPdb(_argv[1]));                                             // Load the PDB
    ok = ok && !FAILED(source_interface->openSession(&session_interface));                                       // Open the session that will query the PDB data
    ok = ok && !FAILED(session_interface->get_globalScope(&global_scope_interface));                             // Get the global scope where all the types live
    ok = ok && global_scope_interface->get_guid(&guid) == S_OK;                                                  // Grab the GUID for debugging purposes
    ok = ok && global_scope_interface->get_age(&age) == S_OK;                                                    // Grab the age

    if (ok) {
        // Print the PDB GUID on the sym store (GUID + AGE)

        printf("%08X%04X%04X%02X%02X%02X%02X%02X%02X%02X%02X",
               guid.Data1, guid.Data2, guid.Data3,
               guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3],
               guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7]);

        if (print_symstore_id && age) {
            printf("%X", age);
        }
        printf("\n");

        CoUninitialize();
        return 0;
    }

    return -1;
}