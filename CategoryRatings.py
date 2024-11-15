import os
import pandas as pd
from transformers import TFAutoModelForSequenceClassification, AutoTokenizer
import tensorflow as tf
from tqdm import tqdm


class ReviewAnalyzer:
    def __init__(self):
        self.model_name = 'nlptown/bert-base-multilingual-uncased-sentiment'
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
        self.model = TFAutoModelForSequenceClassification.from_pretrained(self.model_name)

    def analyze_sentiment(self, review: str):
        inputs = self.tokenizer(review, return_tensors="tf", truncation=True, padding=True, max_length=512)
        logits = self.model(**inputs).logits
        sentiment = tf.argmax(logits, axis=-1).numpy()[0]
        sentiment_label = ['very negative', 'negative', 'neutral', 'positive', 'very positive']
        return sentiment_label[sentiment], sentiment

    def analyze_sentiment_batch(self, reviews):
        inputs = self.tokenizer(reviews, return_tensors="tf", padding=True, truncation=True, max_length=512)
        logits = self.model(**inputs).logits
        sentiments = tf.argmax(logits, axis=-1).numpy()
        sentiment_label = ['very negative', 'negative', 'neutral', 'positive', 'very positive']

        return [(sentiment_label[sent], sent) for sent in sentiments]

    def categorize_review(self, review: str, categories, sentiment_numeric):
        categories_found = {category: 0 for category in categories}

        words = review.lower().split()
        for category, keywords in categories.items():
            match_count = 0
            for word in words:
                if word in keywords:
                    match_count += 1

            categories_found[category] = match_count

        default_score = sentiment_numeric
        return {category: (score if score > 0 else default_score) for category, score in categories_found.items()}


def process_file(input_file, output_file, categories, analyzer, batch_size=50):
    print(f"Starting to process file: {input_file}")

    reviews_df = pd.read_csv(input_file)

    print(f"Columns in CSV: {reviews_df.columns}")

    reviews_df.columns = reviews_df.columns.str.strip()

    processed_data = []

    total_reviews = len(reviews_df)

    for batch_start in tqdm(range(0, total_reviews, batch_size), desc="Processing Batches"):
        batch_end = min(batch_start + batch_size, total_reviews)
        reviews_batch = reviews_df['REVIEW'].iloc[batch_start:batch_end].tolist()
        sentiments_batch = analyzer.analyze_sentiment_batch(
            reviews_batch)


        for idx, row in reviews_df.iloc[batch_start:batch_end].iterrows():
            review = row['REVIEW']
            sentiment_label, sentiment_numeric = sentiments_batch[idx - batch_start]

            categories_found = analyzer.categorize_review(review, categories, sentiment_numeric)

            processed_data.append({
                'REVIEWID': row['IDREVIEW'],
                'HOTELID': row['IDHOTEL'],
                'Cleanliness score': categories_found.get('cleanliness', sentiment_numeric),
                'Price score': categories_found.get('price', sentiment_numeric),
                'Service score': categories_found.get('service', sentiment_numeric),
                'Location score': categories_found.get('location', sentiment_numeric)
            })

        processed_batch_df = pd.DataFrame(processed_data)
        processed_batch_df.to_csv(output_file, mode='a', header=not os.path.exists(output_file), index=False)

        processed_data = []

    print(f"Finished processing file {input_file}")


def main():
    categories = {
        'cleanliness': ['clean', 'dirty', 'filthy', 'unclean', 'spotless', 'hygiene', 'tidiness'],
        'price': ['cheap', 'expensive', 'affordable', 'overpriced', 'value', 'cost', 'bill'],
        'service': ['staff', 'helpful', 'rude', 'friendly', 'unfriendly', 'attentive', 'inattentive', 'service'],
        'location': ['near', 'far', 'central', 'remote', 'proximity', 'located']
    }

    analyzer = ReviewAnalyzer()

    input_dir = r'C:\Users\jayde\OneDrive - Indiana University\Desktop\IUPUI Fall 2024\CIT 44400\Final Project\sentiment_input'
    output_file = r'C:\Users\jayde\OneDrive - Indiana University\Desktop\IUPUI Fall 2024\CIT 44400\Final Project\processed_reviews_output.csv'

    files = [f for f in os.listdir(input_dir) if f.endswith('.csv')]

    if not files:
        print("No CSV files found in the specified directory.")
        return

    for file in files:
        input_file = os.path.join(input_dir, file)

        process_file(input_file, output_file, categories, analyzer, batch_size=30)

    print("Finished processing all files.")


if __name__ == "__main__":
    main()
