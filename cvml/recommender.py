def recommend(topwear, color):
    rules = {
        "shirt": ["black_trousers", "navy_trousers"],
        "tshirt": ["blue_jeans", "black_jeans"],
        "kurta": ["churidar", "pajama"]
    }

    return rules.get(topwear, ["jeans"])
