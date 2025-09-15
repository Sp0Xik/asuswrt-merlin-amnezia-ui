# Amnezia-UI для ASUSWRT-Merlin

Amnezia-UI — это лёгкий веб-интерфейс для управления AmneziaWG (обфусцированный WireGuard) на роутерах ASUS с прошивкой Merlin (версия 384.15+ или 3006.102.1+). Это аналог XRAYUI, но заточен под Amnezia VPN: генерация/импорт конфигов, управление серверами, правилами трафика и фаерволом. Поддержка моделей: RT-AC66U, RT-AC68U, RT-AX58U, TUF-AX5400, RT-AX92U, RT-AX86U, RT-AX88U, GT-AX11000, GT-AXE11000, GT-AX6000, RT-AX86U Pro, RT-AX88U Pro, GT-AX11000 Pro, RT-BE88U.

## Установка
Подключись по SSH к роутеру (нужен JFFS и Entware) и выполни:

wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz && rm -rf /jffs/addons/amnezia-ui && tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons && mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui && chmod 0755 /jffs/scripts/amnezia-ui && sh /jffs/scripts/amnezia-ui install

После установки выйди/войди в веб-интерфейс роутера, перейди в меню **VPN** — появится вкладка **Amnezia**.

## Деинсталляция

/jffs/scripts/amnezia-ui uninstall


## Кастомизация
Для кастомных правил фаервола (IPTables) создай скрипты в `/jffs/amnezia-ui_custom/`:
- `firewall_server` — при запуске в сервер-моде.
- `firewall_client` — при запуске в клиент-моде.
- `firewall_cleanup` — при остановке.
Сделай их исполняемыми: `chmod +x <script>`.

## Зависимости
- AmneziaWG: [GitHub Amnezia](https://github.com/amnezia-vpn/amnezia-client) (мы интегрируем клиентскую часть для конфигов).
- WireGuard (встроен в Merlin).
- SSH-доступ к роутеру.

## Структура проекта
- `scripts/`: Shell-скрипты установки/управления.
- `www/`: Веб-UI (HTML/JS/CSS, как в XRAYUI).
- `configs/`: Примеры AmneziaWG-конфигов.

## Поддержка
- Issues: [Создай тикет](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/issues).
- Форумы: SNBForums (Merlin), Amnezia Discord.

Лицензия: MIT.
