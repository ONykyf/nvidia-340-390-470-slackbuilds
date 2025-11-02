if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications
fi

if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache -f usr/share/icons/hicolor >/dev/null 2>&1
  fi
fi

if [ -x /etc/rc.d/rc.local ] ; then
  if ! grep 'rc.nvidia340' /etc/rc.d/rc.local >/dev/null ; then
cat >> /etc/rc.d/rc.local <<EOF

if [ -x /etc/rc.d/rc.nvidia340 ] ; then
  /etc/rc.d/rc.nvidia340
fi
EOF
  fi
fi

