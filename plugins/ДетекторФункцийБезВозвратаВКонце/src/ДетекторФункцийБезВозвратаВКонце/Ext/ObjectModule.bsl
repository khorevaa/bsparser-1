﻿
 // Простая и эффективная проверка на наличие возврата из функции.
 // Чаще всего возврат просто забывают написать.
 // Нет никакого смысла разбирать сложные случаи,
 // когда пропущен возврат в одной из логических ветвей,
 // так как такие ошибки встречаются редко.
 // Гораздо проще договориться с командой, что функция всегда
 // должна оканчиваться инструкцией Возврат и автоматически
 // проверять код подобным плагином.

Перем Узлы;
Перем ТаблицаТокенов;
Перем ТаблицаОшибок;

Процедура Инициализировать(Парсер, Параметры) Экспорт
	Узлы = Парсер.Узлы();
	ТаблицаТокенов = Парсер.ТаблицаТокенов();
	ТаблицаОшибок = Парсер.ТаблицаОшибок();
КонецПроцедуры

Функция Закрыть() Экспорт
	Возврат Неопределено;
КонецФункции

Функция Подписки() Экспорт
	Перем Подписки;
	Подписки = Новый Массив;
	Подписки.Добавить("ПосетитьОбъявлениеМетода");
	Возврат Подписки;
КонецФункции

Процедура ПосетитьОбъявлениеМетода(ОбъявлениеМетода) Экспорт
	Перем КоличествоОператоров;
	Если ОбъявлениеМетода.Сигнатура.Тип <> Узлы.СигнатураФункции Тогда
		Возврат;
	КонецЕсли;
	КоличествоОператоров = ОбъявлениеМетода.Операторы.Количество();
	Если КоличествоОператоров = 0 Или ОбъявлениеМетода.Операторы[КоличествоОператоров - 1].Тип <> Узлы.ОператорВозврат Тогда
		Текст = СтрШаблон("Последней инструкцией функции `%1()` должен быть `Возврат`""", ОбъявлениеМетода.Сигнатура.Имя);
		Ошибка(Текст, ОбъявлениеМетода.Конец);
	КонецЕсли;
КонецПроцедуры

Процедура Ошибка(Текст, Начало, Конец = Неопределено)
	Если Конец = Неопределено Тогда
		Конец = Начало;
	КонецЕсли;
	ТокенНачала = ТаблицаТокенов[Начало];
	ТокенКонца = ТаблицаТокенов[Конец];
	Ошибка = ТаблицаОшибок.Добавить();
	Ошибка.Источник = "ДетекторФункцийБезВозвратаВКонце";
	Ошибка.ТекстОшибки = Текст;
	Ошибка.ПозицияНачала = ТокенНачала.Начало;
	Ошибка.НомерСтрокиНачала = ТокенНачала.НомерСтроки;
	Ошибка.НомерКолонкиНачала = ТокенНачала.НомерКолонки;
	Ошибка.ПозицияКонца = ТокенКонца.Конец;
	Ошибка.НомерСтрокиКонца = ТокенКонца.НомерСтроки;
	Ошибка.НомерКолонкиКонца = ТокенКонца.НомерКолонки;
КонецПроцедуры