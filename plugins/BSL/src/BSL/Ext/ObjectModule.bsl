﻿
// Транслятор BSL -> BSL

Перем Результат; // array (string)
Перем Отступ; // number

Перем Узлы;         // enum
Перем Токены;        // enum
Перем Операции;     // structure as map[one of Токены](string)

Перем ПоследняяСтрока;
Перем Комментарии;      // map[number](string)

Процедура Инициализировать(ПарсерВстроенногоЯзыка) Экспорт

	Операции = Новый Structure(
		"ЗнакРавно, ЗнакНеРавно, ЗнакМеньше, ЗнакБольше, ЗнакМеньшеИлиРавно, ЗнакБольшеИлиРавно, ЗнакСложения, ЗнакВычитания, ЗнакУмножения, ЗнакДеления, ЗнакОстатка, Или, И, Не",
		"=", "<>", "<", ">", "<=", ">=", "+", "-", "*", "/", "%", "Или", "И", "Не"
	);

	Узлы = ПарсерВстроенногоЯзыка.Узлы();
	Токены = ПарсерВстроенногоЯзыка.Токены();

	ПоследняяСтрока = 1;

	Результат = Новый Массив;
	Отступ = -1;

КонецПроцедуры // Инициализировать()

Функция Подписки() Экспорт
	Перем Подписки;
	Подписки = Новый Массив;
	Подписки.Добавить("ПосетитьМодуль");
	Возврат Подписки;
КонецФункции // Подписки()

Функция Закрыть() Экспорт
	Возврат СтрСоединить(Результат);
КонецФункции // Закрыть()

Процедура ПосетитьМодуль(Модуль, Стек, Счетчики) Экспорт
	Комментарии = Модуль.Комментарии;
	ПосетитьОбъявления(Модуль.Объявления);
	ПосетитьОператоры(Модуль.Операторы);
КонецПроцедуры // ПосетитьМодуль()

Процедура ПосетитьОбъявления(Объявления)
	Отступ = Отступ + 1; // >>
	Для Каждого Объявление Из Объявления Цикл
		ПосетитьОбъявление(Объявление);
	КонецЦикла;
	Отступ = Отступ - 1; // <<
КонецПроцедуры // ПосетитьОбъявления()

Процедура ПосетитьОператоры(Операторы)
	Отступ = Отступ + 1; // >>
	Для Каждого Оператор Из Операторы Цикл
		ПосетитьОператор(Оператор);
	КонецЦикла;
	Отступ = Отступ - 1; // <<
	Отступ();
КонецПроцедуры // ПосетитьОператоры()

#Область ПосетитьОбъявление

Процедура ПосетитьОбъявление(Объявление)
    Перем Тип;
	УстановитьОтступ(Объявление.Место.НомерПервойСтроки);
	Тип = Объявление.Тип;
    Если Тип = Узлы.ОбъявлениеСпискаПеременныхМодуля Тогда
        ПосетитьОбъявлениеСпискаПеременныхМодуля(Объявление);
    ИначеЕсли Тип = Узлы.ОбъявлениеМетода Тогда
        ПосетитьОбъявлениеМетода(Объявление);
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораОбласть
		Или Тип = Узлы.ИнструкцияПрепроцессораКонецОбласти
		Или Тип = Узлы.ИнструкцияПрепроцессораЕсли
		Или Тип = Узлы.ИнструкцияПрепроцессораИначеЕсли
		Или Тип = Узлы.ИнструкцияПрепроцессораИначе
		Или Тип = Узлы.ИнструкцияПрепроцессораКонецЕсли Тогда
		ПосетитьИнструкциюПрепроцессора(Объявление);
    КонецЕсли;
КонецПроцедуры // ПосетитьОбъявление()

Процедура ПосетитьОбъявлениеСпискаПеременныхМодуля(ОбъявлениеСпискаПеременныхМодуля)
	Если ОбъявлениеСпискаПеременныхМодуля.Директивы.Количество() > 0 Тогда
		Результат.Добавить(СтрШаблон("&%1%2", ОбъявлениеСпискаПеременныхМодуля.Директивы, Символы.ПС));
	КонецЕсли;
	ПосетитьПеременные(ОбъявлениеСпискаПеременныхМодуля.ОбъявленияПеременных);
КонецПроцедуры // ПосетитьОбъявлениеСпискаПеременныхМодуля()

Процедура ПосетитьОбъявлениеМетода(ОбъявлениеМетода)
	Если ОбъявлениеМетода.Сигнатура.Тип = Узлы.СигнатураФункции Тогда
		ПосетитьСигнатуруФункции(ОбъявлениеМетода.Сигнатура);
		Если ОбъявлениеМетода.Переменные.Количество() > 0 Тогда
			Результат.Добавить(Символы.ПС);
			Результат.Добавить(Символы.Таб);
			ПосетитьПеременные(ОбъявлениеМетода.Переменные);
			ПоследняяСтрока = ОбъявлениеМетода.Сигнатура.Место.НомерПоследнейСтроки + 1;
		КонецЕсли;
		ПосетитьОператоры(ОбъявлениеМетода.Операторы);
		УстановитьОтступ(ОбъявлениеМетода.Место.НомерПоследнейСтроки);
		Результат.Добавить("КонецФункции");
	Иначе
		ПосетитьСигнатуруПроцедуры(ОбъявлениеМетода.Сигнатура);
		Если ОбъявлениеМетода.Переменные.Количество() > 0 Тогда
			Результат.Добавить(Символы.ПС);
			Результат.Добавить(Символы.Таб);
			ПосетитьПеременные(ОбъявлениеМетода.Переменные);
			ПоследняяСтрока = ОбъявлениеМетода.Сигнатура.Место.НомерПоследнейСтроки + 1;
		КонецЕсли;
    	ПосетитьОператоры(ОбъявлениеМетода.Операторы);
		УстановитьОтступ(ОбъявлениеМетода.Место.НомерПоследнейСтроки);
		Результат.Добавить("КонецПроцедуры");
	КонецЕсли;
КонецПроцедуры // ПосетитьОбъявлениеМетода()

Процедура ПосетитьСигнатуруПроцедуры(ОбъявлениеПроцедуры)
	Если ОбъявлениеПроцедуры.Директивы.Количество() > 0 Тогда
		Результат.Добавить(СтрШаблон("&%1%2", ОбъявлениеПроцедуры.Директивы[0].Директива, Символы.ПС));
	КонецЕсли;
	Результат.Добавить("Процедура ");
	Результат.Добавить(ОбъявлениеПроцедуры.Имя);
	ПосетитьПараметры(ОбъявлениеПроцедуры.Параметры);
	Если ОбъявлениеПроцедуры.Экспорт Тогда
		Результат.Добавить(" Экспорт");
	КонецЕсли;
КонецПроцедуры // ПосетитьСигнатуруПроцедуры()

Процедура ПосетитьСигнатуруФункции(ОбъявлениеФункции)
	Если ОбъявлениеФункции.Директивы.Количество() > 0 Тогда
		Результат.Добавить(СтрШаблон("&%1%2", ОбъявлениеФункции.Директивы[0].Директива, Символы.ПС));
	КонецЕсли;
	Результат.Добавить("Функция ");
	Результат.Добавить(ОбъявлениеФункции.Имя);
	ПосетитьПараметры(ОбъявлениеФункции.Параметры);
	Если ОбъявлениеФункции.Экспорт Тогда
		Результат.Добавить(" Экспорт");
	КонецЕсли;
КонецПроцедуры // ПосетитьСигнатуруФункции()

#КонецОбласти // ПосетитьОбъявление

#Область Выражения

Процедура ПосетитьВыражение(Выражение)
    Перем Тип;
	УстановитьОтступ(Выражение.Место.НомерПервойСтроки);
	Тип = Выражение.Тип;
	Если Тип = Узлы.ВыражениеЛитерал Тогда
        ПосетитьВыражениеЛитерал(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеИдентификатор Тогда
        ПосетитьВыражениеИдентификатор(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеУнарное Тогда
        ПосетитьВыражениеУнарное(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеБинарное Тогда
        ПосетитьВыражениеБинарное(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеНовый Тогда
        ПосетитьВыражениеНовый(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеТернарное Тогда
        ПосетитьВыражениеТернарное(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеСкобочное Тогда
        ПосетитьВыражениеСкобочное(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеНе Тогда
        ПосетитьВыражениеНе(Выражение);
    ИначеЕсли Тип = Узлы.ВыражениеСтроковое Тогда
        ПосетитьВыражениеСтроковое(Выражение);
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражение()

Процедура ПосетитьВыражениеЛитерал(ВыражениеЛитерал)
	ВидЛитерала = ВыражениеЛитерал.Вид;
	Если ВидЛитерала = Токены.Строка Тогда
		Результат.Добавить(СтрШаблон("""%1""", СтрЗаменить(ВыражениеЛитерал.Значение, """", """""")));
	ИначеЕсли ВидЛитерала = Токены.НачалоСтроки Тогда
		Результат.Добавить(СтрШаблон("""%1", ВыражениеЛитерал.Значение));
	ИначеЕсли ВидЛитерала = Токены.ПродолжениеСтроки Тогда
		Результат.Добавить(СтрШаблон("|%1", ВыражениеЛитерал.Значение));
	ИначеЕсли ВидЛитерала = Токены.ОкончаниеСтроки Тогда
		Результат.Добавить(СтрШаблон("|%1""", ВыражениеЛитерал.Значение));
	ИначеЕсли ВидЛитерала = Токены.Число Тогда
		Результат.Добавить(Format(ВыражениеЛитерал.Значение, "NZ=0; NG="));
	ИначеЕсли ВидЛитерала = Токены.ДатаВремя Тогда
		Результат.Добавить(СтрШаблон("'%1'", Format(ВыражениеЛитерал.Значение, "DF=yyyyMMdd; DE=00010101")));
	ИначеЕсли ВидЛитерала = Токены.Истина Или ВидЛитерала = Токены.Ложь Тогда
		Результат.Добавить(Format(ВыражениеЛитерал.Значение, "BF=False; BT=True"));
	ИначеЕсли ВидЛитерала = Токены.Неопределено Тогда
		Результат.Добавить("Неопределено");
	ИначеЕсли ВидЛитерала = Токены.Null Тогда
		Результат.Добавить("Null");
	Иначе
		ВызватьИсключение "Неизвестный литерал";
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражениеЛитерал()

Процедура ПосетитьВыражениеИдентификатор(ВыражениеИдентификатор)
	Результат.Добавить(ВыражениеИдентификатор.Голова.Имя);
	Если ВыражениеИдентификатор.Аргументы <> Неопределено Тогда
		Результат.Добавить("(");
		Отступ = Отступ + 1; // >>
		СписокВыражений(ВыражениеИдентификатор.Аргументы);
		Отступ = Отступ - 1; // <<
		УстановитьОтступ(ВыражениеИдентификатор.Место.НомерПоследнейСтроки);
		Результат.Добавить(")");
	КонецЕсли;
	ПосетитьХвост(ВыражениеИдентификатор.Хвост);
КонецПроцедуры // ПосетитьВыражениеИдентификатор()

Процедура ПосетитьВыражениеУнарное(ВыражениеУнарное)
	Результат.Добавить(Операции[ВыражениеУнарное.Операция]);
	ПосетитьВыражение(ВыражениеУнарное.Операнд);
КонецПроцедуры // ПосетитьВыражениеУнарное()

Процедура ПосетитьВыражениеБинарное(ВыражениеБинарное)
	ПосетитьВыражение(ВыражениеБинарное.ЛевыйОперанд);
	УстановитьОтступ(ВыражениеБинарное.ПравыйОперанд.Место.НомерПервойСтроки);
	Результат.Добавить(СтрШаблон(" %1 ", Операции[ВыражениеБинарное.Операция]));
    ПосетитьВыражение(ВыражениеБинарное.ПравыйОперанд);
КонецПроцедуры // ПосетитьВыражениеБинарное()

Процедура ПосетитьВыражениеНовый(ВыражениеНовый)
    Если ВыражениеНовый.Имя <> Неопределено Тогда
		Результат.Добавить("Новый " + ВыражениеНовый.Имя);
    Иначе
		Результат.Добавить("Новый ");
	КонецЕсли;
	Если ВыражениеНовый.Аргументы.Количество() > 0 Тогда
		Результат.Добавить("(");
		Отступ = Отступ + 1; // >>
		СписокВыражений(ВыражениеНовый.Аргументы);
		Отступ = Отступ - 1; // <<
		УстановитьОтступ(ВыражениеНовый.Место.НомерПоследнейСтроки);
		Результат.Добавить(")");
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражениеНовый()

Процедура ПосетитьВыражениеТернарное(ВыражениеТернарное)
	Результат.Добавить("?(");
	ПосетитьВыражение(ВыражениеТернарное.Выражение);
	Результат.Добавить(", ");
	ПосетитьВыражение(ВыражениеТернарное.Тогда);
	Результат.Добавить(", ");
	ПосетитьВыражение(ВыражениеТернарное.Иначе);
	Результат.Добавить(")");
	ПосетитьХвост(ВыражениеТернарное.Хвост);
КонецПроцедуры // ПосетитьВыражениеТернарное()

Процедура ПосетитьВыражениеСкобочное(ВыражениеСкобочное)
	Результат.Добавить("(");
	Отступ = Отступ + 1; // >>
	ПосетитьВыражение(ВыражениеСкобочное.Выражение);
	Отступ = Отступ - 1; // <<
	УстановитьОтступ(ВыражениеСкобочное.Место.НомерПоследнейСтроки);
	Результат.Добавить(")");
КонецПроцедуры // ПосетитьВыражениеСкобочное()

Процедура ПосетитьВыражениеНе(ВыражениеНе)
	Результат.Добавить("Не ");
	ПосетитьВыражение(ВыражениеНе.Выражение);
КонецПроцедуры // ПосетитьВыражениеНе()

Процедура ПосетитьВыражениеСтроковое(ВыражениеСтроковое)
	Если ВыражениеСтроковое.Элементы.Количество() > 1 Тогда
		Для Каждого Литерал Из ВыражениеСтроковое.Элементы Цикл
			УстановитьОтступ(Литерал.Место.НомерПервойСтроки);
			ПосетитьВыражениеЛитерал(Литерал);
		КонецЦикла;
	Иначе
		ПосетитьВыражение(ВыражениеСтроковое.Элементы[0]);
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражениеСтроковое()

#КонецОбласти // Выражения

#Область Операторы

Процедура ПосетитьОператор(Оператор)
	УстановитьОтступ(Оператор.Место.НомерПервойСтроки);
	Тип = Оператор.Тип;
	Если Тип = Узлы.ОператорПрисваивания Тогда
        ПосетитьОператорПрисваивания(Оператор);
    ИначеЕсли Тип = Узлы.ОператорВозврат Тогда
        ПосетитьОператорВозврат(Оператор);
    ИначеЕсли Тип = Узлы.ОператорПрервать Тогда
        ПосетитьОператорПрервать(Оператор);
    ИначеЕсли Тип = Узлы.ОператорПродолжить Тогда
        ПосетитьОператорПродолжить(Оператор);
    ИначеЕсли Тип = Узлы.ОператорВызватьИсключение Тогда
        ПосетитьОператорВызватьИсключение(Оператор);
    ИначеЕсли Тип = Узлы.ОператорВыполнить Тогда
        ПосетитьОператорВыполнить(Оператор);
    ИначеЕсли Тип = Узлы.ОператорВызоваПроцедуры Тогда
        ПосетитьОператорВызоваПроцедуры(Оператор);
    ИначеЕсли Тип = Узлы.ОператорЕсли Тогда
        ПосетитьОператорЕсли(Оператор);
    ИначеЕсли Тип = Узлы.ОператорПока Тогда
        ПосетитьОператорПока(Оператор);
    ИначеЕсли Тип = Узлы.ОператорДля Тогда
        ПосетитьОператорДля(Оператор);
    ИначеЕсли Тип = Узлы.ОператорДляКаждого Тогда
        ПосетитьОператорДляКаждого(Оператор);
    ИначеЕсли Тип = Узлы.ОператорПопытка Тогда
        ПосетитьОператорПопытка(Оператор);
    ИначеЕсли Тип = Узлы.ОператорПерейти Тогда
        ПосетитьОператорПерейти(Оператор);
    ИначеЕсли Тип = Узлы.ОператорМетка Тогда
        ПосетитьОператорМетка(Оператор);
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораОбласть
		Или Тип = Узлы.ИнструкцияПрепроцессораКонецОбласти
		Или Тип = Узлы.ИнструкцияПрепроцессораЕсли
		Или Тип = Узлы.ИнструкцияПрепроцессораИначеЕсли
		Или Тип = Узлы.ИнструкцияПрепроцессораИначе
		Или Тип = Узлы.ИнструкцияПрепроцессораКонецЕсли Тогда
		ПосетитьИнструкциюПрепроцессора(Оператор);
    КонецЕсли;
КонецПроцедуры // Операторы()

Процедура ПосетитьОператорПрисваивания(ОператорПрисваивания)
    ПосетитьВыражениеИдентификатор(ОператорПрисваивания.ЛевыйОперанд);
	Результат.Добавить(" = ");
	ПосетитьВыражение(ОператорПрисваивания.ПравыйОперанд);
	Результат.Добавить(";");
КонецПроцедуры // ПосетитьОператорПрисваивания()

Процедура ПосетитьОператорВозврат(ОператорВозврат)
	Результат.Добавить("Возврат ");
	Если ОператорВозврат.Выражение <> Неопределено Тогда
        ПосетитьВыражение(ОператорВозврат.Выражение);
	КонецЕсли;
	Результат.Добавить(";");
КонецПроцедуры // ПосетитьОператорВозврат()

Процедура ПосетитьОператорПрервать(ОператорПрервать)
	Результат.Добавить("Прервать;");
КонецПроцедуры // ПосетитьОператорПрервать()

Процедура ПосетитьОператорПродолжить(ОператорПродолжить)
	Результат.Добавить("Продолжить;");
КонецПроцедуры // ПосетитьОператорПродолжить()

Процедура ПосетитьОператорВызватьИсключение(ОператорВызватьИсключение)
	Результат.Добавить("ВызватьИсключение ");
	Если ОператорВызватьИсключение.Выражение <> Неопределено Тогда
        ПосетитьВыражение(ОператорВызватьИсключение.Выражение);
	КонецЕсли;
	Результат.Добавить(";");
КонецПроцедуры // ПосетитьОператорВызватьИсключение()

Процедура ПосетитьОператорВыполнить(ОператорВыполнить)
	Результат.Добавить("Выполнить(");
	ПосетитьВыражение(ОператорВыполнить.Выражение);
	Результат.Добавить(");");
КонецПроцедуры // ПосетитьОператорВыполнить()

Процедура ПосетитьОператорВызоваПроцедуры(ОператорВызоваПроцедуры)
    ПосетитьВыражениеИдентификатор(ОператорВызоваПроцедуры.Идентификатор);
	Результат.Добавить(";");
КонецПроцедуры // ПосетитьОператорВызоваПроцедуры()

Процедура ПосетитьОператорЕсли(ОператорЕсли)
	Результат.Добавить("Если ");
	ПосетитьВыражение(ОператорЕсли.Выражение);
	Результат.Добавить(" Тогда ");
    ПосетитьОператоры(ОператорЕсли.Тогда);
    Если ОператорЕсли.ИначеЕсли <> Неопределено Тогда
        Для Каждого ОператорИначеЕсли Из ОператорЕсли.ИначеЕсли Цикл
			УстановитьОтступ(ОператорИначеЕсли.Место.НомерПервойСтроки);
			ПосетитьОператорИначеЕсли(ОператорИначеЕсли);
        КонецЦикла;
    КонецЕсли;
    Если ОператорЕсли.Иначе <> Неопределено Тогда
		УстановитьОтступ(ОператорЕсли.Иначе.Место.НомерПервойСтроки);
		ПосетитьОператорИначе(ОператорЕсли.Иначе);
	КонецЕсли;
	УстановитьОтступ(ОператорЕсли.Место.НомерПоследнейСтроки);
	Результат.Добавить("КонецЕсли;");
КонецПроцедуры // ПосетитьОператорЕсли()

Процедура ПосетитьОператорИначеЕсли(ОператорИначеЕсли)
	Результат.Добавить("ИначеЕсли ");
	ПосетитьВыражение(ОператорИначеЕсли.Выражение);
	Результат.Добавить(" Тогда ");
    ПосетитьОператоры(ОператорИначеЕсли.Тогда);
КонецПроцедуры // ПосетитьОператорИначеЕсли()

Процедура ПосетитьОператорИначе(ОператорИначе)
	Результат.Добавить("Иначе ");
    ПосетитьОператоры(ОператорИначе.Операторы);
КонецПроцедуры // ПосетитьОператорИначе()

Процедура ПосетитьОператорПока(ОператорПока)
	Результат.Добавить("Пока ");
	ПосетитьВыражение(ОператорПока.Выражение);
	Результат.Добавить(" Цикл");
    ПосетитьОператоры(ОператорПока.Операторы);
	УстановитьОтступ(ОператорПока.Место.НомерПоследнейСтроки);
	Результат.Добавить("КонецЦикла;");
КонецПроцедуры // ПосетитьОператорПока()

Процедура ПосетитьОператорДля(ОператорДля)
	Результат.Добавить("Для ");
	ПосетитьВыражениеИдентификатор(ОператорДля.Идентификатор);
	Результат.Добавить(" = ");
	ПосетитьВыражение(ОператорДля.Начало);
	Результат.Добавить(" По ");
	ПосетитьВыражение(ОператорДля.Конец);
	Результат.Добавить(" Цикл ");
	ПосетитьОператоры(ОператорДля.Операторы);
	УстановитьОтступ(ОператорДля.Место.НомерПоследнейСтроки);
	Результат.Добавить("КонецЦикла;");
КонецПроцедуры // ПосетитьОператорДля()

Процедура ПосетитьОператорДляКаждого(ОператорДляКаждого)
	Результат.Добавить("Для Каждого ");
	ПосетитьВыражениеИдентификатор(ОператорДляКаждого.Идентификатор);
	Результат.Добавить(" Из ");
	ПосетитьВыражение(ОператорДляКаждого.Коллекция);
	Результат.Добавить(" Цикл ");
	ПосетитьОператоры(ОператорДляКаждого.Операторы);
	УстановитьОтступ(ОператорДляКаждого.Место.НомерПоследнейСтроки);
	Результат.Добавить("КонецЦикла;");
КонецПроцедуры // ПосетитьОператорДляКаждого()

Процедура ПосетитьОператорПопытка(ОператорПопытка)
	Результат.Добавить("Попытка ");
	ПосетитьОператоры(ОператорПопытка.Попытка);
	УстановитьОтступ(ОператорПопытка.Исключение.Место.НомерПервойСтроки);
	ПосетитьОператорИсключение(ОператорПопытка.Исключение);
	УстановитьОтступ(ОператорПопытка.Место.НомерПоследнейСтроки);
	Результат.Добавить("КонецПопытки;");
КонецПроцедуры // ПосетитьОператорПопытка()

Процедура ПосетитьОператорИсключение(ОператорИсключение)
	Результат.Добавить("Исключение ");
    ПосетитьОператоры(ОператорИсключение.Операторы);
КонецПроцедуры // ПосетитьОператорИсключение()

Процедура ПосетитьОператорПерейти(ОператорПерейти)
	Результат.Добавить(СтрШаблон("Перейти ~%1%2", ОператорПерейти.Метка, ";"));
КонецПроцедуры // ПосетитьОператорПерейти()

Процедура ПосетитьОператорМетка(ОператорМетка)
	Результат.Добавить(СтрШаблон("~%1:", ОператорМетка.Метка));
КонецПроцедуры // ПосетитьОператорМетка()

// TODO: ПосетитьОператорДобавитьОбработчик, ПосетитьОператорУдалитьОбработчик

#КонецОбласти // Операторы

#Область Препроцессор

Процедура ПосетитьВыражениеПрепроцессора(ВыражениеПрепроцессора)
	Перем Тип;
	УстановитьОтступ(ВыражениеПрепроцессора.Место.НомерПервойСтроки);
	Тип = ВыражениеПрепроцессора.Тип;
	Если Тип = Узлы.ВыражениеПрепроцессораСимвол Тогда
		ПосетитьВыражениеПрепроцессораСимвол(ВыражениеПрепроцессора);
	ИначеЕсли Тип = Узлы.ВыражениеПрепроцессораБинарное Тогда
		ПосетитьВыражениеПрепроцессораБинарное(ВыражениеПрепроцессора);
	ИначеЕсли Тип = Узлы.ВыражениеПрепроцессораНе Тогда
		ПосетитьВыражениеПрепроцессораНе(ВыражениеПрепроцессора);
	ИначеЕсли Тип = Узлы.ВыражениеПрепроцессораСкобочное Тогда
		ПосетитьВыражениеПрепроцессораСкобочное(ВыражениеПрепроцессора);
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражениеПрепроцессора()

Процедура ПосетитьВыражениеПрепроцессораСимвол(ВыражениеПрепроцессораСимвол)
	Результат.Добавить(ВыражениеПрепроцессораСимвол.Символ);
КонецПроцедуры // ПосетитьВыражениеПрепроцессораСимвол()

Процедура ПосетитьВыражениеПрепроцессораБинарное(ВыражениеПрепроцессораБинарное)
	ПосетитьВыражениеПрепроцессора(ВыражениеПрепроцессораБинарное.ЛевыйОперанд);
	Результат.Добавить(СтрШаблон(" %1 ", Операции[ВыражениеПрепроцессораБинарное.Операция]));
	ПосетитьВыражениеПрепроцессора(ВыражениеПрепроцессораБинарное.ПравыйОперанд);
КонецПроцедуры // ПосетитьВыражениеПрепроцессораБинарное()

Процедура ПосетитьВыражениеПрепроцессораНе(ВыражениеПрепроцессораНе)
	Результат.Добавить("Не ");
	ПосетитьВыражениеПрепроцессора(ВыражениеПрепроцессораНе.Выражение);
КонецПроцедуры // ПосетитьВыражениеПрепроцессораНе()

Процедура ПосетитьВыражениеПрепроцессораСкобочное(ВыражениеПрепроцессораСкобочное)
	Результат.Добавить("(");
	Отступ = Отступ + 1; // >>
	ПосетитьВыражениеПрепроцессора(ВыражениеПрепроцессораСкобочное.Выражение);
	Отступ = Отступ - 1; // <<
	УстановитьОтступ(ВыражениеПрепроцессораСкобочное.Место.НомерПоследнейСтроки);
	Результат.Добавить(")");
КонецПроцедуры // ПосетитьВыражениеПрепроцессораСкобочное()

Процедура ПосетитьИнструкциюПрепроцессора(ИнструкцияПрепроцессора)
	Перем Тип;
	Тип = ИнструкцияПрепроцессора.Тип;
	Если Тип = Узлы.ИнструкцияПрепроцессораОбласть Тогда
		Результат.Добавить("#Область ");
		Результат.Добавить(ИнструкцияПрепроцессора.Имя);
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораКонецОбласти Тогда
		Результат.Добавить("#КонецОбласти");
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораЕсли Тогда
		Результат.Добавить("#Если ");
		ПосетитьВыражениеПрепроцессора(ИнструкцияПрепроцессора.Выражение);
		Результат.Добавить(" Тогда");
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораИначеЕсли Тогда
		Результат.Добавить("#ИначеЕсли ");
		ПосетитьВыражениеПрепроцессора(ИнструкцияПрепроцессора.Выражение);
		Результат.Добавить(" Тогда");
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораИначе Тогда
		Результат.Добавить("#Иначе");
	ИначеЕсли Тип = Узлы.ИнструкцияПрепроцессораКонецЕсли Тогда
		Результат.Добавить("#КонецЕсли");
	КонецЕсли;
КонецПроцедуры // ПосетитьИнструкциюПрепроцессора()

#КонецОбласти // Препроцессор

#Область Вспомогательное

Процедура Отступ()
	Для Индекс = 1 По Отступ Цикл
		Результат.Добавить(Символы.Таб);
	КонецЦикла;
КонецПроцедуры // Отступ()

Процедура УстановитьОтступ(НоваяСтрока)
	Для ПоследняяСтрока = ПоследняяСтрока По НоваяСтрока - 1 Цикл
		Комментарий = Комментарии[ПоследняяСтрока];
		Если Комментарий <> Неопределено Тогда
			Результат.Добавить(" //" + Комментарий);
		КонецЕсли;
		Результат.Добавить(Символы.ПС); Отступ();
	КонецЦикла;
КонецПроцедуры // УстановитьОтступ()

Процедура ПосетитьПеременные(Переменные)
	Перем Буфер, ОбъявлениеПеременной;
	Результат.Добавить("Перем ");
	Буфер = Новый Массив;
	Для Каждого ОбъявлениеПеременной Из Переменные Цикл
		Если ОбъявлениеПеременной.Property("Экспорт") И ОбъявлениеПеременной.Экспорт Тогда
			Буфер.Добавить(ОбъявлениеПеременной.Имя + " Экспорт");
		Иначе
			Буфер.Добавить(ОбъявлениеПеременной.Имя);
		КонецЕсли;
	КонецЦикла;
	Если Буфер.Количество() > 0 Тогда
		Результат.Добавить(СтрСоединить(Буфер, ", "));
	КонецЕсли;
	Результат.Добавить(";");
КонецПроцедуры // ПосетитьПеременные()

Процедура ПосетитьПараметры(Параметры)
	Перем ОбъявлениеПараметра;
	Результат.Добавить("(");
	Если Параметры.Количество() > 0 Тогда
		Для Каждого ОбъявлениеПараметра Из Параметры Цикл
			Если ОбъявлениеПараметра.ПоЗначению Тогда
				Результат.Добавить("Знач ");
			КонецЕсли;
			Результат.Добавить(ОбъявлениеПараметра.Имя);
			Если ОбъявлениеПараметра.Значение <> Неопределено Тогда
				Результат.Добавить(" = ");
				ПосетитьВыражение(ОбъявлениеПараметра.Значение);
			КонецЕсли;
			Результат.Добавить(", ");
		КонецЦикла;
		Результат[Результат.ВГраница()] = ")";
	Иначе
		Результат.Добавить(")");
	КонецЕсли;
КонецПроцедуры // ПосетитьПараметры()

Процедура СписокВыражений(Выражения)
	Если Выражения.Количество() > 0 Тогда
		Для Каждого Выражение Из Выражения Цикл
			Если Выражение = Неопределено Тогда
				Результат.Добавить("");
			Иначе
				ПосетитьВыражение(Выражение);
			КонецЕсли;
			Результат.Добавить(", ");
		КонецЦикла;
		Результат[Результат.ВГраница()] = "";
	КонецЕсли;
КонецПроцедуры // СписокВыражений()

Процедура ПосетитьХвост(Хвост)
	Для Каждого Элемент Из Хвост Цикл
		Если Элемент.Тип = Узлы.ВыражениеПоле Тогда
			Результат.Добавить(".");
			Результат.Добавить(Элемент.Имя);
			Если Элемент.Аргументы <> Неопределено Тогда
				Результат.Добавить("(");
				Отступ = Отступ + 1; // >>
				СписокВыражений(Элемент.Аргументы);
				Отступ = Отступ - 1; // <<
				УстановитьОтступ(Элемент.Место.НомерПоследнейСтроки);
				Результат.Добавить(")");
			КонецЕсли;
		ИначеЕсли Элемент.Тип = Узлы.ВыражениеИндекс Тогда
			Результат.Добавить("[");
			ПосетитьВыражение(Элемент.Выражение);
			Результат.Добавить("]");
		Иначе
			ВызватьИсключение "Неизвестный тип узла";
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры // ПосетитьХвост()

#КонецОбласти // Вспомогательное
