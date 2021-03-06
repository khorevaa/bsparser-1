﻿
// Пример использования стека

Перем Типы;
Перем ТаблицаОшибок;
Перем Стек;

Процедура Открыть(Парсер, Параметры) Экспорт
	Типы = Парсер.Типы();
	Стек = Парсер.Стек();
	ТаблицаОшибок = Парсер.ТаблицаОшибок();
КонецПроцедуры // Открыть()

Функция Закрыть() Экспорт
	Возврат Неопределено;
КонецФункции // Закрыть()

Функция Подписки() Экспорт
	Перем Подписки;
	Подписки = Новый Массив;
	Подписки.Добавить("ПосетитьВыражениеТернарное");
	Возврат Подписки;
КонецФункции // Подписки()

#Область РеализацияПодписок

Процедура ПосетитьВыражениеТернарное(ВыражениеТернарное) Экспорт
	Для Каждого Родитель Из Стек Цикл
		Если Родитель.Тип = Типы.ВыражениеТернарное Тогда
			Ошибка("Вложенный тернарный оператор", ВыражениеТернарное.Начало, ВыражениеТернарное.Конец);
			Прервать;
		КонецЕсли; 
	КонецЦикла; 
КонецПроцедуры // ПосетитьВыражениеТернарное()

#КонецОбласти // РеализацияПодписок

Процедура Ошибка(Текст, Начало, Конец = Неопределено, ЕстьЗамена = Ложь)
	Ошибка = ТаблицаОшибок.Добавить();
	Ошибка.Источник = "ДетекторВложенныхТернарныхОператоров";
	Ошибка.Текст = Текст;
	Ошибка.ПозицияНачала = Начало.Позиция;
	Ошибка.НомерСтрокиНачала = Начало.НомерСтроки;
	Ошибка.НомерКолонкиНачала = Начало.НомерКолонки;
	Если Конец = Неопределено Или Конец = Начало Тогда
		Ошибка.ПозицияКонца = Начало.Позиция + Начало.Длина;
		Ошибка.НомерСтрокиКонца = Начало.НомерСтроки;
		Ошибка.НомерКолонкиКонца = Начало.НомерКолонки + Начало.Длина;
	Иначе
		Ошибка.ПозицияКонца = Конец.Позиция + Конец.Длина;
		Ошибка.НомерСтрокиКонца = Конец.НомерСтроки;
		Ошибка.НомерКолонкиКонца = Конец.НомерКолонки + Конец.Длина;
	КонецЕсли;
	Ошибка.ЕстьЗамена = ЕстьЗамена;
КонецПроцедуры
