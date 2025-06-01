import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import Message

# Токен бота
TOKEN = "7932620585:AAGzZHCKAZZlxDnwVM2eAuChJbaA7aA7jRE"

# ID администратора и ID группы/канала для заявок
ADMIN_ID = 6299981913
GROUP_ID = -1002440129279  # UKR44 канал

bot = Bot(token=TOKEN)
dp = Dispatcher()

# Простое хранилище состояний
user_data = {}

@dp.message(Command("start"))
async def start(message: Message):
    await message.answer("Привет! Это Ukr44 Бот.\nХочешь стать частью проекта?\n\nКак тебя зовут?")
    user_data[message.from_user.id] = {"step": "name"}

@dp.message()
async def process(message: Message):
    user_id = message.from_user.id
    if user_id not in user_data:
        await message.answer("Напиши /start, чтобы начать.")
        return

    step = user_data[user_id].get("step")

    if step == "name":
        user_data[user_id]["name"] = message.text
        user_data[user_id]["step"] = "skills"
        await message.answer("Что ты умеешь? Чем занимаешься?")
    elif step == "skills":
        user_data[user_id]["skills"] = message.text
        user_data[user_id]["step"] = "why"
        await message.answer("Почему тебе откликается проект Ukr44?")
    elif step == "why":
        user_data[user_id]["why"] = message.text
        user_data[user_id]["step"] = "done"

        data = user_data[user_id]
        summary = (
            f"📝 Новая заявка от @{message.from_user.username or 'не указано'}\n\n"
            f"👤 Имя: {data['name']}\n"
            f"💼 Навыки: {data['skills']}\n"
            f"💬 Почему хочет участвовать:\n{data['why']}"
        )

        await bot.send_message(chat_id=ADMIN_ID, text=summary)
        await bot.send_message(chat_id=GROUP_ID, text=summary)
        await message.answer("Спасибо! Мы скоро с тобой свяжемся")

# Запуск
async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())