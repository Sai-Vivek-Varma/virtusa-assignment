import re

def moderator():
    posts = [
        "Luffy: Hey, check out my new course at https://www.anurag-university.edu.in",
        "Zoro: you all are so bad and toxic! I hate everyone in this BaD Toxic Hateful group.",
        "Nami: Who wants to join the TOXIC club?",
        "Sanji: Another bad link here      http://badhatefultoxic-site.com to earn money",
        "Usopp: Have a baD day folks."
    ]

    banned_words = ["bad", "toxic", "hate"]

    links = [] # Storing the links found in the posts
    user_flags = {} # Tracking the no of flags for each user

    screened = len(posts)
    cleaned, blocked = 0, 0 

    for post in posts:
        parts = post.split(": ", 1) # Splitting the post after ':' to differentiate user and content
        if len(parts) != 2:
            continue

        user, content = parts[0], parts[1]

        if user not in user_flags:
            user_flags[user] = 0

        original = content

        # Appraoch 1: Misses edge cases like "bAd", "BaD" etc.

        # for word in banned_words:
        #     if word in content.lower():
        #         content = content.replace(word, "***")
        #         content = content.replace(word.capitalize(), "***")
        #         content = content.replace(word.upper(), "***")

        # Approach 2: Using find() to get the occurance of the banned word and replacing it with "***"

        for word in banned_words:
            temp = content.lower()
            i = 0

            while i < len(temp):
                idx = temp.find(word, i)
                if idx == -1:
                    break
                content = content[:idx] + "***" + content[idx+len(word):]
                i = idx + 3

        # Approach 3: Using regex

        # for word in banned_words:
        #     content = re.sub(word, "***", content, flags=re.IGNORECASE)

        for w in original.split(): # Splitting words at the whitespace to check for links
            if w.startswith("http"):
                links.append(w)

        if original != content:
            flag_count = content.count("***")

            if flag_count > 1: # If more than 1 banned word is found, block the post
                blocked += 1
                user_flags[user] += 1
                print(f"[REJECTED] - Post by {user} was blocked.")
            else:
                cleaned += 1
                user_flags[user] += 1
                print(f"[CLEANED] - {user}: {content}")
        else:
            print(f"[PASSED] - {user}: {content}")

    with open("links_found.txt", "w") as f:
        for link in links:
            f.write(link + "\n")

    print("\n--- Moderation Summary ---")
    print(f"Total Posts Screened: {screened} | Cleaned: {cleaned} | Blocked: {blocked}")
    print("User Flags Tracker:", user_flags)
    print("Extracted links saved to links_found.txt")


moderator()