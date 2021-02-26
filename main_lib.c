int vlc_entry();

__attribute__((visibility("default")))
int entrypoint() { vlc_entry(); }
