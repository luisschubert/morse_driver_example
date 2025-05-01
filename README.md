# morse driver module example

builds kernel modules `morse.ko` and `dot11ah.ko` from x86 host for aarch64 target from [**MorseMicro**/morse_driver](https://github.com/MorseMicro/morse_driver)

just uses a random kernel version for example purposes.

## how to build
```bash
nix build .#morse-driver
```

### build outputs
```
result/
└── lib
    └── modules
        └── 6.1.135
            └── misc
                ├── dot11ah.ko
                └── morse.ko
```


### module config flags used
```
"CONFIG_WLAN_VENDOR_MORSE=m"
"CONFIG_MORSE_SPI=y"
"CONFIG_MORSE_USER_ACCESS=y"
"CONFIG_MORSE_DEBUG=y"
"CONFIG_MORSE_VENDOR_COMMAND=y"
"CONFIG_MORSE_COUNTRY=US"
```

## Notes

had to add
```
  postPatch = ''
    substituteInPlace Makefile \
      --replace "-Werror" ""
  '';
```
