__attribute__((visibility("default")))
int extern_symbol();

__attribute__((visibility("default")))
int vlc_entry() { return extern_symbol(); }
