
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Копировать файл");

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "Источник", "Файл источник");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "Приемник", "Файл/каталог приемник (если оканчивается на ""\"", то каталог)");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-replace",
		"Перезаписывать файл-приемник");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-delsource",
		"Удалить файл-источник");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	Источник		= ПараметрыКоманды["Источник"];
	Приемник		= ПараметрыКоманды["Приемник"];
	Перезаписывать	= ПараметрыКоманды["-replace"];
	УдалитьИсточник	= ПараметрыКоманды["-delsource"];

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(Источник) Тогда
		Лог.Ошибка("Не указан файл-источник");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(Приемник) Тогда
		Лог.Ошибка("Не указан файл/каталог приемник");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Попытка
		ОписаниеРезультата = "";
		
		Результат = КомандаКопироватьФайл(Источник, Приемник, Перезаписывать, УдалитьИсточник, ОписаниеРезультата);

		Если Не ПустаяСтрока(ОписаниеРезультата) Тогда
			Лог.Информация("Вывод команды: " + ОписаниеРезультата);
		КонецЕсли;
		
		Если Результат = 0 Тогда
			Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
		КонецЕсли;

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка("Вывод команды: " + ОписаниеРезультата + Символы.ПС + ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

Функция КомандаКопироватьФайл(Источник, Приемник, Перезаписывать = Истина, УдалитьИсточник = Ложь, ОписаниеРезультата = "") Экспорт

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("xcopy");
	КомандаРК.ДобавитьПараметр(Источник);
	КомандаРК.ДобавитьПараметр(Приемник);
	КомандаРК.ДобавитьПараметр("/Y");
	КомандаРК.ДобавитьПараметр("/Z");
	КомандаРК.ДобавитьПараметр("/V");
	КомандаРК.ДобавитьПараметр("/J");

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если УдалитьИсточник Тогда
		КомандаУдалитьФайл(Источник);
	КонецЕсли;
	
	Возврат КодВозврата = 0;
	
КонецФункции //КомандаКопироватьФайл()

Функция КомандаУдалитьФайл(ПутьКФайлу, ОписаниеРезультата = "") Экспорт

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("del");
	КомандаРК.ДобавитьПараметр("/F ");
	КомандаРК.ДобавитьПараметр("/Q ");
	КомандаРК.ДобавитьПараметр(ПутьКФайлу);

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Возврат КодВозврата = 0;
	
КонецФункции //КомандаУдалитьФайл()

Лог = Логирование.ПолучитьЛог("ktb.app.copydb");