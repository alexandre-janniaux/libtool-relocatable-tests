int vlc_entry();
int vlc_entry2();

__attribute__((visibility("default")))
int entrypoint() { vlc_entry(); return vlc_entry2(); }
