from flask import Flask, render_template, request
import pickle
import os
import numpy as np

app = Flask(__name__)

# Absolute path to the file
file_path = os.path.join(os.path.dirname(__file__), "C:\\Users\\shash\\OneDrive\\Desktop\\Book Recommender\\popular.pkl")
file_path1 = os.path.join(os.path.dirname(__file__), "C:\\Users\\shash\\Book Recommender\\similarity_scores.pkl")
file_path2 = os.path.join(os.path.dirname(__file__), "C:\\Users\\shash\\Book Recommender\\my.pkl")
file_path3 = os.path.join(os.path.dirname(__file__), "C:\\Users\\shash\\Book Recommender\\pt.pkl")

# Load the dataframe
try:
    my = pickle.load(open(file_path2, "rb"))
    pt = pickle.load(open(file_path3, "rb"))
    ss = pickle.load(open(file_path1, "rb"))
    popular_df = pickle.load(open(file_path, 'rb'))
    print("DataFrame loaded successfully")
except Exception as e:
    print(f"Error loading DataFrame: {e}")

@app.route('/')
def index():
    try:
        book_name = list(popular_df['Book-Title'].values)
        author = list(popular_df['Book-Author'].values)
        image = list(popular_df['Image-URL-M'].values)
        votes = list(popular_df['num_ratings'].values)
        rating = list(popular_df['avg_ratings'].values)

        return render_template(
            'index.html',
            book_name=book_name,
            author=author,
            image=image,
            votes=votes,
            rating=rating
        )
    except Exception as e:
        print(f"Error in index function: {e}")
        return "Error loading data"

@app.route('/recommend')
def recommend():
    return render_template('recommend.html')

@app.route('/recommend_books', methods=['POST'])
def recommend_books():
    user_input = request.form.get('user_input')
    try:
        index = np.where(pt.index == user_input)[0][0]
        similar_items = sorted(list(enumerate(ss[index])), key=lambda x: x[1], reverse=True)[1:9]
        data = []
        for i in similar_items:
            item = []
            temp_df = my[my['Book-Title'] == pt.index[i[0]]]
            item.extend(list(temp_df.drop_duplicates('Book-Title')['Book-Title'].values))
            item.extend(list(temp_df.drop_duplicates('Book-Title')['Book-Author'].values))
            item.extend(list(temp_df.drop_duplicates('Book-Title')['Image-URL-M'].values))
            data.append(item)
        return render_template('recommend.html', data=data)
    except IndexError:
        print(f"User input {user_input} not found in pt index")
        return render_template('recommend.html', data=[], message="Book not found.")
    except Exception as e:
        print(f"Error in recommend_books function: {e}")
        return "Error in recommendation process"

if __name__ == '__main__':
    app.run(debug=True)
