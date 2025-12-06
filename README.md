<details>
  <summary>
    <h3>Содержание</h3>
  </summary>

- [О НАС](#о-нас)
- [Workspace-зависимости](#workspace-зависимости)
  - [`neurosdk2`](#neurosdk2)
  - [Классические плагины](#классические-плагины)
  - [FFI-плагины](#ffi-плагины)
  - [Прочие библиотеки](#прочие-библиотеки)

</details>

## О НАС

Команда LGTM (Looks goot to me) состоит из пяти человек:
1) *Капитан Сорока Виктора*
Создание production-интерфейса и связь работы основной логики и приложения
2) *Дизайнер Бацурина София*
Создание начального дизайна для приложение, создание презентации для защиты проекта
3) *Программист Бутко Борис*
Создание debug-приложения для первичной связи основной логики для тестирования и отладки
4) *Программист Вихренко Олег*
Создание основного алгоритма по работе с пришедшими от датчика данными, их оброботка для дальнейшей передачи
5) *Программист Попов Роман*
Создание функций, которые отвечают за интерпретацию обработанных данных с датчиков в компьютерные сигналы

## Workspace-зависимости

### [`neurosdk2`](neurosdk2)

Это локальный форк оригинального Flutter плагина [`neurosdk2`](https://pub.dev/packages/neurosdk2), цель которого - исправление ошибок компиляции нативного кода. Оригинальная лицензия не была изменена.

Список изменений:

- Обновлена версия генератора сообщений [`pigeon`](https://pub.dev/packages/pigeon) и заново сгенерированы сообщения.

- Исправлены ошибки сборки проекта:

  ```diff
  diff --git a/neurosdk2/windows/utils.cpp b/neurosdk2/windows/utils.cpp
  index 75add91..6390135 100644
  --- a/neurosdk2/windows/utils.cpp
  +++ b/neurosdk2/windows/utils.cpp
  @@ -28,15 +28,14 @@ flutter::EncodableList SensorInfosToList(SensorInfo* sensors, int32_t szSensors)
    while (szSensors--)
    {
      SensorInfo info = sensors[szSensors];
  -		flutter::EncodableMap sensor{
  -				{flutter::EncodableValue("Name"), flutter::EncodableValue(std::string(info.Name))},
  -				{flutter::EncodableValue("Address"), flutter::EncodableValue(std::string(info.Address))},
  -				{flutter::EncodableValue("SerialNumber"), flutter::EncodableValue(std::string(info.SerialNumber))},
  -				{flutter::EncodableValue("SensModel"), flutter::EncodableValue((int32_t)info.SensModel)},
  -				{flutter::EncodableValue("SensFamily"), flutter::EncodableValue((int32_t)SensFamilyToOrdinal(info.SensFamily))},
  -				{flutter::EncodableValue("PairingRequired"), flutter::EncodableValue(info.PairingRequired ? true : false)},
  -				{flutter::EncodableValue("RSSI"), flutter::EncodableValue((int32_t)info.RSSI)}
  -		};
  +    flutter::EncodableMap sensor;
  +    sensor.insert(std::make_pair(flutter::EncodableValue("Name"), flutter::EncodableValue(std::string(info.Name))));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("Address"), flutter::EncodableValue(std::string(info.Address))));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("SerialNumber"), flutter::EncodableValue(std::string(info.SerialNumber))));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("SensModel"), flutter::EncodableValue((int32_t)info.SensModel)));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("SensFamily"), flutter::EncodableValue((int32_t)SensFamilyToOrdinal(info.SensFamily))));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("PairingRequired"), flutter::EncodableValue(info.PairingRequired ? true : false)));
  +    sensor.insert(std::make_pair(flutter::EncodableValue("RSSI"), flutter::EncodableValue((int32_t)info.RSSI)));
      sensorsList.push_back(sensor);
    }
    return sensorsList;
  @@ -48,10 +47,9 @@ flutter::EncodableList CallibriSignalDataToList(CallibriSignalData* data, int32_
    for (int i = 0; i < size; i++) {
      CallibriSignalData it = data[i];
      std::vector<double> list(it.Samples, it.Samples + it.SzSamples);
  -		flutter::EncodableMap map{
  -			{flutter::EncodableValue("PackNum"), it.PackNum},
  -			{flutter::EncodableValue("Samples"), list }
  -		};
  +		flutter::EncodableMap map;
  +		map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
  +		map.insert(std::make_pair(flutter::EncodableValue("Samples"), flutter::EncodableValue(list)));
      dataList.push_back(map);
    }
    return dataList;
  @@ -63,10 +61,9 @@ flutter::EncodableList CallibriRespirationDataToList(CallibriRespirationData* da
    for (int i = 0; i < size; i++) {
      CallibriRespirationData it = data[i];
      std::vector<double> list(it.Samples, it.Samples + it.SzSamples);
  -		flutter::EncodableMap map{
  -			{flutter::EncodableValue("PackNum"), it.PackNum},
  -			{flutter::EncodableValue("Samples"), list }
  -		};
  +		flutter::EncodableMap map;
  +		map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
  +		map.insert(std::make_pair(flutter::EncodableValue("Samples"), flutter::EncodableValue(list)));
      dataList.push_back(map);
    }
    return dataList;
  @@ -77,10 +74,9 @@ flutter::EncodableList CallibriEnvelopeDataToList(CallibriEnvelopeData* data, in
    flutter::EncodableList dataList{};
    for (int i = 0; i < size; i++) {
      CallibriEnvelopeData it = data[i];
  -		flutter::EncodableMap map{
  -			{flutter::EncodableValue("PackNum"), it.PackNum},
  -			{flutter::EncodableValue("Sample"), it.Sample }
  -		};
  +		flutter::EncodableMap map;
  +    map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
  +    map.insert(std::make_pair(flutter::EncodableValue("Sample"), flutter::EncodableValue(it.Sample)));
      dataList.push_back(map);
    }
    return dataList;
  @@ -400,4 +396,4 @@ std::string CreateUUID()
    CT2CA pszConvertedAnsiString(C);
    std::string strStd(pszConvertedAnsiString);
    return strStd;
  -}
  \ No newline at end of file
  +}
  ```

### Классические плагины

Тут пока пусто.

### FFI-плагины

- [`device_info_ffi`](device_info_ffi) (by [@deminearchiver](https://github.com/deminearchiver)) - порт официального плагина [`device_info_plus`]() на использование FFI и JNI.

### Прочие библиотеки

- [`layout`](layout) (by [@deminearchiver](https://github.com/deminearchiver)) - виджеты для компоновки и рендеринга. Предназначена для замещения некоторых виджетов из [`package:flutter/widgets.dart`](https://api.flutter.dev/flutter/widgets/).

- [`material`](material) (by [@deminearchiver](https://github.com/deminearchiver)) - библиотека системы дизайна Material Design 3. Предназначена для **полного** замещения [`package:flutter/material.dart`](https://api.flutter.dev/flutter/material/).

- [`shapes`](shapes) (by [@deminearchiver](https://github.com/deminearchiver)) - кроссплатформенный порт библиотеки [`androidx.graphics.shapes`](https://developer.android.com/reference/kotlin/androidx/graphics/shapes/package-summary).
