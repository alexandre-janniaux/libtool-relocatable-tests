#include <iostream>

extern "C" {

__attribute__((visibility("default")))
int extern_symbol();

__attribute__((visibility("default")))
int vlc_entry2() {
    /* To pull C++ dependencies */
    std::cout << "Entry2" << std::endl;
    return extern_symbol();
}

}
