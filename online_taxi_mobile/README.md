# Taxi App — Flutter

## Структура

```
lib/
├── main.dart
├── core/
│   ├── grpc/grpc_client.dart        # gRPC подключение к бэку
│   ├── router/app_router.dart       # Навигация (go_router)
│   ├── theme/app_theme.dart         # Тема (тёмная, жёлтый акцент)
│   └── services/
│       ├── storage_service.dart     # Хранение JWT токенов
│       ├── fcm_service.dart         # Firebase push-уведомления
│       └── device_service.dart      # device_id
├── features/
│   ├── auth/                        # Вход / Регистрация
│   ├── passenger/                   # Карта, заказ поездки
│   └── driver/                      # Экран водителя
└── gen/                             # Сгенерированные proto файлы
```

## Запуск

```bash
flutter pub get
flutter run
```

## Подключение к бэку

Поменяй хост в `lib/core/grpc/grpc_client.dart`:
```dart
const _host = '10.0.2.2'; // Android эмулятор
// const _host = '192.168.x.x'; // реальное устройство
```

## Генерация proto

См. `lib/gen/README.md`j

## Firebase

1. Положи `google-services.json` в `android/app/`
2. Для iOS: `GoogleService-Info.plist` в `ios/Runner/`

## Тест авторизации (моковый режим)

- Любой email + любой пароль → пассажир
- Email содержащий "driver" → водитель
