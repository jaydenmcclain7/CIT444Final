import pandas as pd
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer

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

        return ' '.join(processed_tokens)
    else:
        return ""

reviews_df = pd.read_csv('C:/Users/jayde/OneDrive - Indiana University/Desktop/IUPUI Fall 2024/CIT 44400/Final Project/reviews.csv')


print(reviews_df.head())

reviews_df['ProcessedReview'] = reviews_df['REVIEW'].apply(process_review)

processed_reviews_file = 'C:/Users/jayde/OneDrive - Indiana University/Desktop/IUPUI Fall 2024/CIT 44400/Final Project/processed_reviews.csv'
reviews_df.to_csv(processed_reviews_file, index=False)

print(f"Processed reviews have been saved to: {processed_reviews_file}")