# 🚀 Amnezia-UI v3.1.0 — Универсальный плагин для ASUSWRT-Merlin

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE) [![Platform](https://img.shields.io/badge/Platform-ASUSWRT--Merlin-blue.svg)](#совместимость) [![Version](https://img.shields.io/badge/Version-v3.1.0-orange.svg)](#releases) [![Build](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/actions/workflows/github-actions-build.yml/badge.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/actions)

> **🔥 Полная интеграция AmneziaWG с DPI-обходом прямо в веб-интерфейс роутера!**

**Amnezia-UI** — это продвинутый плагин, который интегрирует [AmneziaWG](https://github.com/amnezia-vpn/amneziawg-go) (WireGuard с технологиями обхода DPI) прямо в веб-интерфейс роутера ASUSWRT-Merlin. Поддерживает как оригинальный Merlin, так и форк от gnuton.

## ✨ Ключевые возможности

| Функция | Описание | Статус |
|---------|-----------|--------|
| 🌐 **Web UI интеграция** | Кнопка в таблице VPN Client для управления конфигами | ✅ |
| 🔧 **AmneziaWG 1.5** | Поддержка CPS вкл/выкл, пресеты I1–I5, S1–S4, H1–H4 | ✅ |
| 🎯 **Селективная маршрутизация** | Маршрутизация по доменам/IP с использованием ipset | ✅ |
| 🖥️ **Универсальная архитектура** | ARMv7, ARMv8, MIPS — все в одном пакете | ✅ |
| ⚡ **Быстрая установка** | Установка в одну строку + CLI инструменты | ✅ |

## 📋 Совместимость

### Поддерживаемые прошивки:
- **ASUSWRT-Merlin**: 3004.388.x и выше
- **gnuton форк**: Все актуальные версии

### Протестированные модели:

| Модель | Архитектура | Статус |
|--------|-------------|--------|
| RT-AX88U | ARMv8 | ✅ Протестировано |
| RT-AX86U | ARMv8 | ✅ Протестировано |
| TUF-AX5400 | ARMv7 | ✅ Протестировано |
| RT-AC68U | ARMv7 | ✅ Протестировано |
| RT-AX58U | ARMv7 | ✅ Совместимо |
| RT-AC86U | ARMv8 | ✅ Совместимо |

### Совместимость с другими плагинами:
- ✅ VPN Director
- ✅ YazFi  
- ✅ Diversion
- ✅ Skynet

## 🛠️ Системные требования

| Компонент | Требование |
|-----------|------------|
| **Прошивка** | ASUSWRT-Merlin 3004.388.x+ |
| **Entware** | Установлен и настроен (opkg) |
| **Свободное место** | ~50 МБ в /opt во время установки |
| **Интернет** | Доступ для скачивания компонентов |

## 🚀 Быстрая установка

### Метод 1: Merlin Install Pattern (NEW! 🔥)

**Современный паттерн установки в стиле YazFi/XRAYUI для ASUSWRT-Merlin:**

```bash
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal-v31-merlin.sh | sh
```

**Что делает этот скрипт:**
- ✅ Скачивает пакет в `/tmp`
- ✅ Извлекает архив в `/jffs/addons/amneziaui`
- ✅ Перемещает скрипты в `/jffs/scripts`
- ✅ Устанавливает права `chmod 0755`
- ✅ Автоматически запускает `sh /jffs/scripts/amnezia-ui install`
- ✅ Чистый вывод в stdout без лишнего логирования
- ✅ Полная совместимость с Merlin и gnuton форком

### Метод 2: Универсальная установка (классический)

```bash
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal-v31.sh | sh
```

### После установки:

1. **Управление через CLI:**
   ```bash
   amnezia-ui help
   amnezia-ui add /path/to/config.conf
   amnezia-ui start
   amnezia-ui status
   ```

2. **Веб-интерфейс:**
   ```bash
   amnezia-ui web start
   ```
   Затем перейдите: `http://[IP_роутера]:8080`

3. **Интеграция в Merlin UI:**
   - Откройте `VPN → VPN Client`
   - Найдите кнопку "Amnezia-UI" в таблице

## 📱 Скриншоты

### Веб-интерфейс
![Web Interface](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/assets/placeholder-web.png)

### Интеграция в Merlin
![Merlin Integration](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/assets/placeholder-merlin.png)

## 🔧 Использование

### Добавление конфигураций

```bash
# Добавить конфигурацию
amnezia-ui add /path/to/your/config.conf

# Запустить интерфейс
amnezia-ui start amnezia0

# Проверить статус
amnezia-ui status
```

### Веб-управление

```bash
# Запустить веб-сервер
amnezia-ui web start

# Остановить веб-сервер  
amnezia-ui web stop

# Проверить статус веб-сервера
amnezia-ui web status
```

## 🐛 Устранение неполадок

### Проверка статуса
```bash
amnezia-ui status
ip link show | grep amnezia
```

### Просмотр логов
```bash
amnezia-ui log
tail -f /jffs/amnezia-ui/amnezia.log
```

### Переустановка
```bash
amnezia-ui uninstall
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal-v31-merlin.sh | sh
```

## 📋 Известные проблемы

- **Проблема**: Интерфейс не поднимается
  - **Решение**: Проверьте права доступа: `ls -la /jffs/amnezia-ui/`
  
- **Проблема**: Веб-интерфейс недоступен
  - **Решение**: Убедитесь что порт 8080 не занят: `netstat -ln | grep :8080`

## 🤝 Участие в разработке

1. Сделайте Fork репозитория
2. Создайте ветку для новой функции (`git checkout -b feature/AmazingFeature`)
3. Сделайте Commit изменений (`git commit -m 'Add some AmazingFeature'`)
4. Сделайте Push в ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📄 Лицензия

Распространяется под лицензией MIT. См. `LICENSE` для дополнительной информации.

## 🙏 Благодарности

- [AmneziaVPN](https://github.com/amnezia-vpn) за потрясающий AmneziaWG
- Сообществу ASUSWRT-Merlin за фидбэк и тестирование
- Разработчикам YazFi и XRAYUI за вдохновение паттерна установки

---

⭐ **Поставьте звездочку, если проект оказался полезным!**
