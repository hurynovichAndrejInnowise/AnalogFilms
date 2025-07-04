⏳ Сколько бы заняло времени без AI (в часах) 
36?

🕒 Фактическое время с AI (в часах) 
14

🤖 Время работы именно с AI (в часах) 
12

🧩 Использованные AI-помощники 
Claude Sonnet 4.0 и Alex for Xcode

💬 Топ-3 успешных промпта

1. Напиши приложение для iOS. Это будет каталог фотоплёнок. Используй SwiftUI, target 18.0, используй архитектуру MMVM+C, для DI используй Swinject, для загрузки изображений используй Kingfisher. Используй самые новые доступные методы решения задачи. Используй @Observable. Для хранения данных используй SwiftData, обеспечь в ней хранение добавленных в избранное плёнок. Начни с создания экрана FilmsList и FilmDetail. (далее полное описание запросов и ответов API).
2. Сортировки не применяются. Дело может быть в том, что ты не пробрасываешь их в метод внутри NetworkService. Добавь логи, я протестирую сортировки ещё раз и отправлю тебе результат.
3. Полностью пересмотри решение по дизайну этого экрана, придумай новый responsive modern design. 

🧱 1–2 неудачных промпта

1. Не работает пагинация, исправь. (тут он не только не исправил, но и полностью разрушил существующую частично рабочую network логику).
2. Проведи рефактор всего приложения, сохрани логику, но убери неиспользуемый код, оптимизируй функции (по-итогу не работало почти ничего).

Посмотрев на [демо](https://youtube.com/shorts/7fGrrPdEJCY?si=VsGdxMybXVysqVD-), можно сказать, что вроде всё выглядит неплохо, видны некоторые визуальные недостатки, но казалось бы, это можно просто исправить, однако это не так. 

В действительности код находится в плохом состоянии, многие решения AI-агента полностью строятся на bad practice’ах, исправление части багов требует полной переработки созданной AI реализации. 
Код неоднообразный, даже если приложить к сообщению в чат весь проект, он всё равно будет пытаться применить самое простое, часто «костыльное» решение, не в стиле остального проекта. 
Часто просьба исправить маленький недостаток приводит к полному переписыванию целых экранов, так как чат за несколько итераций не может понять причину проблемы и просто пытается применить новое решение, ломая старое, теряя связь с другими элементами приложения.

При этом промпты про визуальный интерфейс дают отличный результат. Да, созданные им элементы вряд ли можно будет переиспользовать, но смотреться они будут хорошо, а главное созданы они будут очень быстро. 

Очень плохой результат с логикой. Самостоятельно сразу сделать полностью рабочую логику, а тем более найти ошибку почти не может. Чаще проще полностью удалить его решение, открывать новый чат, чтобы он не тащил старый контекст, и после этого просить его придумывать новое решение в надежде на то, что оно будет работать сразу, иначе попытки либо самостоятельного исправления, либо исправления самим чатом приводят к потерям времени соизмеримым с написанием кода вручную с нуля. 

В принципе, вполне вероятно то, что построив всю архитектуру приложения полностью без участия чата, результат мог бы быть лучше. 

Можно сказать, что он действительно хорош на этапе набросков, но доверять ему то, что пойдёт в прод без полного анализа и переосмысления, наверное, нельзя, по крайней мере пока. 