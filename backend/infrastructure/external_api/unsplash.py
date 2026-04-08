import httpx
from core.config import settings

async def fetch_recipe_image(query: str) -> str | None:
    """
    Выполняет запрос к Unsplash API для поиска картинки по запросу (search_query).
    В случае ошибки или отсутствия ключа возвращает URL-заглушку.
    """
    default_image = "https://via.placeholder.com/600x400.png?text=Recipe+Image"
    
    if not settings.UNSPLASH_ACCESS_KEY:
        return default_image

    url = "https://api.unsplash.com/search/photos"
    params = {
        "query": query,
        "per_page": 1,
        "orientation": "landscape"
    }
    headers = {
        "Authorization": f"Client-ID {settings.UNSPLASH_ACCESS_KEY}"
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, headers=headers)
            response.raise_for_status()
            data = response.json()
            if data.get("results"):
                return data["results"][0]["urls"]["regular"]
    except Exception as e:
        print(f"Error fetching image from Unsplash: {e}")
        
    return default_image
