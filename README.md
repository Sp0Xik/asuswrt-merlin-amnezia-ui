# 🚀 Amnezia-UI v3.1.0 — Универсальный плагин для ASUSWRT-Merlin

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-ASUSWRT--Merlin-blue.svg)](#совместимость)
[![Version](https://img.shields.io/badge/Version-v3.1.0-orange.svg)](#releases)
[![Build](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/actions/workflows/github-actions-build.yml/badge.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/actions)

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

### Метод 1: Установка в одну строку (рекомендуется)

```bash
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal-v31.sh | sh
```
