# -*- coding: utf-8 -*-
"""AI_G_P_2025.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1c8YgvZsnroYV9yc16ZW2-hDzFqaON0NU

Importing the Dependencies
"""

!pip install flask pyngrok --quiet

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn.metrics import accuracy_score

"""Data Collection and Analysis

PIMA Diabetes Dataset
"""

# loading the diabetes dataset to a pandas DataFrame
diabetes_dataset = pd.read_csv('/content/dogfinal3.csv')

# printing the first 5 rows of the dataset
diabetes_dataset.head()

# number of rows and Columns in this dataset
diabetes_dataset.shape

# getting the statistical measures of the data
diabetes_dataset.describe()

diabetes_dataset['diseases'].value_counts()

"""0 --> Non-Diabetic

1 --> Diabetic
"""

diabetes_dataset.groupby('diseases').mean()

# separating the data and labels
X = diabetes_dataset.drop(columns = 'diseases', axis=1)
Y = diabetes_dataset['diseases']

print(X)

print(Y)

"""Train Test Split"""

X_train, X_test, Y_train, Y_test = train_test_split(X,Y, test_size = 0.2, stratify=Y, random_state=2)

print(X.shape, X_train.shape, X_test.shape)

"""Training the Model"""

classifier = svm.SVC(kernel='linear')

#training the support vector Machine Classifier
classifier.fit(X_train, Y_train)

"""Model Evaluation

Accuracy Score
"""

# accuracy score on the training data
X_train_prediction = classifier.predict(X_train)
training_data_accuracy = accuracy_score(X_train_prediction, Y_train)

print('Accuracy score of the training data : ', training_data_accuracy)

# accuracy score on the test data
X_test_prediction = classifier.predict(X_test)
test_data_accuracy = accuracy_score(X_test_prediction, Y_test)

print('Accuracy score of the test data : ', test_data_accuracy)

"""Making a Predictive System"""

print("write o if no, 1 if yes appearing of symptomps in order :")
print("fever|	vomiting	|paralysis|	reducedappetite|	coughing|	dischargefromeyes|	hyperkeratosis")
print("nasaldischarge	lethargy	sneezing	diarrhea	depression	difficultyinbreathing	pain	")
print(" skinsores	inflammation_eyes	anorexia	seizures	dehydration	weightloss	bloodystool	")
print("weakness	inflammation_mouth	rapidheartbeat	fatigue	swollenbelly	laziness	anemia	")
print("fainting	reversesneezing	gagging	lameness	stiffness	limping	increasedthirst	")
print("increasedurination	excesssalivation	aggression	foamingatmouth	difficultyinswallowing")
print("irritable	pica	hydrophobia	highlyexcitable	shivering	jaundice	decreasedthirst")
print("decreasedurination	bloodinurine	palegums	ulcersinmouth	badbreath ")


input_data = (0,1,0,0,1,0.1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0)

# changing the input_data to numpy array
input_data_as_numpy_array = np.asarray(input_data)

# reshape the array as we are predicting for one instance
input_data_reshaped = input_data_as_numpy_array.reshape(1,-1)

# Making the prediction
prediction = classifier.predict(input_data_reshaped)

# Printing the predicted disease
print(f'Predicted disease: {prediction[0]}')

"""Saving the trained model"""

import pickle

filename = 'diseases_model.sav'
pickle.dump(classifier, open(filename, 'wb'))

# loading the saved model
loaded_model = pickle.load(open('diseases_model.sav', 'rb'))

print("write o if no, 1 if yes appearing of symptomps in order :")
print("fever|	vomiting	|paralysis|	reducedappetite|	coughing|	dischargefromeyes|	hyperkeratosis")
print("nasaldischarge	lethargy	sneezing	diarrhea	depression	difficultyinbreathing	pain	")
print(" skinsores	inflammation_eyes	anorexia	seizures	dehydration	weightloss	bloodystool	")
print("weakness	inflammation_mouth	rapidheartbeat	fatigue	swollenbelly	laziness	anemia	")
print("fainting	reversesneezing	gagging	lameness	stiffness	limping	increasedthirst	")
print("increasedurination	excesssalivation	aggression	foamingatmouth	difficultyinswallowing")
print("irritable	pica	hydrophobia	highlyexcitable	shivering	jaundice	decreasedthirst")
print("decreasedurination	bloodinurine	palegums	ulcersinmouth	badbreath ")


input_data = (0,1,0,0,1,0.1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0)

# changing the input_data to numpy array
input_data_as_numpy_array = np.asarray(input_data)

# reshape the array as we are predicting for one instance
input_data_reshaped = input_data_as_numpy_array.reshape(1,-1)

# Making the prediction
prediction = classifier.predict(input_data_reshaped)

# Printing the predicted disease
print(f'Predicted disease: {prediction[0]}')

for column in X.columns:
  print(column)



!pip install flask numpy scikit-learn pandas

!pip install --upgrade --user flask numpy scikit-learn pandas

!pip install flask
!pip install numpy
!pip install scikit-learn
!pip install pandas

!pip install flask numpy scikit-learn pandas pyngrok

from flask_ngrok import run_with_ngrok

from pyngrok import ngrok

ngrok.set_auth_token("2wXallyQrG1DOsI069zng6CioIr_5vs1WeVFaNX5j6DC1DA5W")

!pip install flask pyngrok --quiet

from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
import pickle
from pyngrok import ngrok

app = Flask(__name__)

# ===== تحميل النموذج والبيانات =====
model = pickle.load(open("diseases_model.sav", "rb"))
dataset = pd.read_csv("dogfinal3.csv")

symptoms_list = [col for col in dataset.columns if col != 'diseases']

# ===== جدول شدة الأعراض يدوي =====
severity_scores = {
    "caninedistemper": {
        'Excellent': ['difficultyinbreathing', 'seizures', 'depression'],
        'Good': ['fever', 'vomiting', 'paralysis', 'reducedappetite', 'coughing', 'dischargefromeyes',
                 'nasaldischarge', 'lethargy', 'sneezing', 'diarrhea', 'pain', 'skinsores',
                 'inflammation_eyes', 'anorexia'],
        'Fair': ['hyperkeratosis']
    },
    "rabies": {
        'Excellent': ['hydrophobia', 'seizures', 'paralysis', 'difficultyinswallowing',
                      'foamingatmouth', 'aggression', 'highlyexcitable'],
        'Good': ['fever', 'vomiting', 'reducedappetite', 'lethargy', 'lameness', 'irritable'],
        'Fair': ['pica', 'excesssalivation']
    },
    "leptospirosis": {
        'Excellent': ['difficultyinbreathing', 'jaundice', 'bloodinurine'],
        'Good': ['fever', 'vomiting', 'reducedappetite', 'coughing', 'nasaldischarge',
                 'lethargy', 'diarrhea', 'depression', 'weakness', 'stiffness', 'limping', 'dehydration'],
        'Fair': ['increasedthirst', 'increasedurination', 'shivering', 'laziness', 'bloodinstool']
    },
    "kennelcough": {
        'Good': ['coughing', 'difficultyinbreathing', 'gagging'],
        'Fair': ['fever', 'vomiting', 'reducedappetite', 'dischargefromeyes',
                 'nasaldischarge', 'lethargy', 'sneezing', 'weakness', 'reversesneezing']
    },
    "kidneydisease": {
        'Excellent': ['seizures', 'bloodinurine', 'depression'],
        'Good': ['vomiting', 'reducedappetite', 'lethargy', 'diarrhea', 'weightloss', 'weakness', 'lameness',
                 'increasedthirst', 'increasedurination', 'palegums', 'ulcersinmouth', 'badbreath'],
        'Fair': ['decreasedthirst', 'decreasedurination']
    },
    "heartworm": {
        'Excellent': ['difficultyinbreathing', 'fainting', 'rapidheartbeat'],
        'Good': ['coughing', 'reducedappetite', 'lethargy', 'weightloss', 'fatigue',
                 'swollenbelly', 'laziness'],
        'Fair': ['anemia']
    },
    "canineparvovirus": {
        'Excellent': ['rapidheartbeat', 'bloodystool', 'diarrhea', 'vomiting', 'dehydration'],
        'Good': ['fever', 'reducedappetite', 'lethargy', 'depression', 'pain', 'inflammation_eyes',
                 'anorexia', 'weightloss', 'weakness', 'inflammation_mouth'],
        'Fair': ['vomiting', 'diarrhea']
    }
}

value_map = {'Excellent': 3, 'Good': 2, 'Fair': 1}
severity_table = pd.DataFrame(0, index=symptoms_list, columns=severity_scores.keys())

for disease, levels in severity_scores.items():
    for level, symptoms in levels.items():
        for symptom in symptoms:
            if symptom in severity_table.index:
                severity_table.at[symptom, disease] = value_map[level]

# === دالة التصنيف بناءً على الأعراض ===
def classify_disease(symptoms, disease_name):
    count_3 = count_2 = count_1 = over = 0
    weight_3, weight_2, weight_1 = 0.5, 0.3, 0.2

    for symptom in symptoms:
        value = severity_table.at[symptom, disease_name] if symptom in severity_table.index else 0
        if value:
            over += 1
            if value == 3:
                count_3 += 1
            elif value == 2:
                count_2 += 1
            elif value == 1:
                count_1 += 1

    total_symptoms = (severity_table[disease_name] > 0).sum()
    if over and total_symptoms:
        score = round((count_3 / over * weight_3 + count_2 / over * weight_2 + count_1 / over * weight_1) * 100 * (count_3 / total_symptoms), 2)
    else:
        score = 0

    if count_3 > 0 or score >= 80:
        return score, "Excellent"
    elif score >= 50:
        return score, "Good"
    elif score >= 20:
        return score, "Fair"
    else:
        return score, "Poor"

# ==== Route الرئيسي ====
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "الرجاء إرسال بيانات الأعراض."}), 400

        input_vector = [float(data.get(symptom, 0)) for symptom in symptoms_list]
        symptoms_present = [symptom for symptom in symptoms_list if data.get(symptom, 0) in [1, "1", "true", True]]

        # تنبؤ رئيسي من الموديل
        predicted_disease = model.predict([input_vector])[0]

        # حساب التصنيفات اليدوية
        ranked_diseases = []
        for disease in severity_scores.keys():
            score, prognosis = classify_disease(symptoms_present, disease)
            ranked_diseases.append({
                "disease": disease,
                "severity_score": score,
                "prognosis": prognosis
            })

        ranked_diseases.sort(key=lambda x: x["severity_score"], reverse=True)

        # تنسيق الإخراج
        output = {
            "message": "تم ترتيب الأمراض حسب أعلى نسبة تطابق",
            "observed_symptoms": symptoms_present,
            "predictions": []
        }

        # أولًا: المرض الأكثر احتمالًا حسب النموذج
        output["predictions"].append({"most_likely_by_model": predicted_disease})

        # بعد ذلك: أعلى 3 أمراض بناءً على severity score
        for disease_info in ranked_diseases[:3]:
            output["predictions"].append({
                "disease": disease_info["disease"],
                "severity_score": disease_info["severity_score"],
                "prognosis": disease_info["prognosis"]
            })

        return jsonify(output)

    except Exception as e:
        return jsonify({"error": f"حدث خطأ: {str(e)}"}), 500

# ==== ngrok ====
ngrok.set_auth_token("2wXallyQrG1DOsI069zng6CioIr_5vs1WeVFaNX5j6DC1DA5W")
public_url = ngrok.connect(5000)
print(f"\U0001F680 رابط API: {public_url}")

app.run(port=5000, debug=True, use_reloader=False)