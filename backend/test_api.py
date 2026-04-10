import requests
import time

BASE_URL = "http://localhost:8000"


def test_fridge_scan():
    print("1. Testing fridge scan...")
    # Читаем реальный файл
    with open("fridge.jpg", "rb") as f:
        img_data = f.read()
    files = {'file': ('fridge.jpg', img_data, 'image/jpeg')}

    response = requests.post(f"{BASE_URL}/api/v1/fridge/scan", files=files)
    assert response.status_code == 200, f"Error: {response.text}"

    data = response.json()
    task_id = data["task_id"]
    status = data["status"]

    print(f"   Success! task_id: {task_id}, status: {status}")
    return task_id


def test_polling(task_id):
    print("2. Polling for results...")
    for i in range(10):  # 10 attempts
        response = requests.get(f"{BASE_URL}/api/v1/tasks/{task_id}")
        assert response.status_code == 200, f"Error: {response.text}"

        data = response.json()
        if data["status"] == "processing":
            print(f"   attempt {i+1}: still processing...")
            time.sleep(10)
        elif data["status"] == "done":
            print("   Success! Got done status.")
            print(f"   Ingredients: {data['result']['ingredients']}")
            print(
                f"   First Recipe Title: {data['result']['recipes'][0]['title']}")
            print(
                f"   First Recipe Image: {data['result']['recipes'][0]['image_url']}")
            return True
        else:
            print(f"   Error: {data}")
            return False
    print("   Timeout!")
    return False


if __name__ == "__main__":
    t_id = test_fridge_scan()
    time.sleep(1)  # Ждем секунду для уверенности что redis записал данные
    test_polling(t_id)
