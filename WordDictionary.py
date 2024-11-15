import pandas as pd
from collections import Counter
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
import nltk

nltk.download('punkt')
nltk.download('stopwords')
nltk.download('wordnet')

lemmatizer = WordNetLemmatizer()
stop_words = set(stopwords.words('english'))

def process_review(review_text):
    if isinstance(review_text, str):
        tokens = word_tokenize(review_text)

        processed_tokens = [
            lemmatizer.lemmatize(word.lower())
            for word in tokens if word.isalnum() and word.lower() not in stop_words
        ]

        return processed_tokens
    else:
        return []

processed_reviews_file = 'C:/Users/jayde/OneDrive - Indiana University/Desktop/IUPUI Fall 2024/CIT 44400/Final Project/processed_reviews.csv'
reviews_df = pd.read_csv(processed_reviews_file)

if 'ProcessedReviewTokens' not in reviews_df.columns:
    raise ValueError("The 'ProcessedReviewTokens' column is missing in the CSV file.")

word_counter = Counter()

for review_tokens in reviews_df['ProcessedReviewTokens']:
    tokens = review_tokens.split()
    word_counter.update(tokens)

sorted_word_list = sorted(word_counter.items(), key=lambda x: x[1], reverse=True)

print("Top 20 most common words and their counts:")
for word, count in sorted_word_list[:20]:
    print(f"{word}: {count}")

word_dict_file = 'C:/Users/jayde/OneDrive - Indiana University/Desktop/IUPUI Fall 2024/CIT 44400/Final Project/sorted_word_frequency_dict.csv'
sorted_word_freq_df = pd.DataFrame(sorted_word_list, columns=['Word', 'Count'])
sorted_word_freq_df.to_csv(word_dict_file, index=False)

print(f"\nSorted word frequency dictionary has been saved to: {word_dict_file}")
