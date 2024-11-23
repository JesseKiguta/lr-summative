# Import necessary modules
from fastapi import FastAPI, HTTPException
import joblib
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import numpy as np

# Initialize FastAPI app
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load best performing model
model = joblib.load("linear_regression_model.pkl")

# Define prediction input
class PredictionInput(BaseModel):
    Hours_Studied: float = Field(..., ge=0, description="Number of hours studied")
    Attendance: float = Field(..., ge=0, le=100, description="Attendance percentage")
    Sleep_Hours: float = Field(..., ge=0, description="Average hours of sleep")
    Previous_Scores: float = Field(..., ge=0, le=100, description="Average of previous scores")
    Tutoring_Sessions: int = Field(..., ge=0, description="Number of tutoring sessions")
    Physical_Activity: int = Field(..., ge=0, description="Hours of physical activity")
    Parental_Involvement_Low: int = Field(..., ge=0, le=1, description="Indicator for low parental involvement")
    Parental_Involvement_Medium: int = Field(..., ge=0, le=1, description="Indicator for medium parental involvement")
    Access_to_Resources_Low: int = Field(..., ge=0, le=1, description="Indicator for low access to resources")
    Access_to_Resources_Medium: int = Field(..., ge=0, le=1, description="Indicator for medium access to resources")
    Extracurricular_Activities_Yes: int = Field(..., ge=0, le=1, description="Participation in extracurricular activities")
    Motivation_Level_Low: int = Field(..., ge=0, le=1, description="Indicator for low motivation level")
    Motivation_Level_Medium: int = Field(..., ge=0, le=1, description="Indicator for medium motivation level")
    Internet_Access_Yes: int = Field(..., ge=0, le=1, description="Indicator for internet access")
    Family_Income_Low: int = Field(..., ge=0, le=1, description="Indicator for low family income")
    Family_Income_Medium: int = Field(..., ge=0, le=1, description="Indicator for medium family income")
    Teacher_Quality_Low: int = Field(..., ge=0, le=1, description="Indicator for low teacher quality")
    Teacher_Quality_Medium: int = Field(..., ge=0, le=1, description="Indicator for medium teacher quality")
    School_Type_Public: int = Field(..., ge=0, le=1, description="Indicator for public school type")
    Peer_Influence_Neutral: int = Field(..., ge=0, le=1, description="Indicator for neutral peer influence")
    Peer_Influence_Positive: int = Field(..., ge=0, le=1, description="Indicator for positive peer influence")
    Learning_Disabilities_Yes: int = Field(..., ge=0, le=1, description="Indicator for learning disabilities")
    Parental_Education_Level_High_School: int = Field(..., ge=0, le=1, description="Indicator for high school parental education")
    Parental_Education_Level_Postgraduate: int = Field(..., ge=0, le=1, description="Indicator for postgraduate parental education")
    Distance_from_Home_Moderate: int = Field(..., ge=0, le=1, description="Indicator for moderate distance from home")
    Distance_from_Home_Near: int = Field(..., ge=0, le=1, description="Indicator for near distance from home")
    Gender_Male: int = Field(..., ge=0, le=1, description="Indicator for male gender")

# GET and POST requests for the API
@app.get("/")
def read_root():
    return {"message": "Welcome to the Prediction API for Student Exam Scores"}

@app.post("/predict/")
def predict(input_data: PredictionInput):
    try:
        input_features = np.array([[
            input_data.Hours_Studied,
            input_data.Attendance,
            input_data.Sleep_Hours,
            input_data.Previous_Scores,
            input_data.Tutoring_Sessions,
            input_data.Physical_Activity,
            input_data.Parental_Involvement_Low,
            input_data.Parental_Involvement_Medium,
            input_data.Access_to_Resources_Low,
            input_data.Access_to_Resources_Medium,
            input_data.Extracurricular_Activities_Yes,
            input_data.Motivation_Level_Low,
            input_data.Motivation_Level_Medium,
            input_data.Internet_Access_Yes,
            input_data.Family_Income_Low,
            input_data.Family_Income_Medium,
            input_data.Teacher_Quality_Low,
            input_data.Teacher_Quality_Medium,
            input_data.School_Type_Public,
            input_data.Peer_Influence_Neutral,
            input_data.Peer_Influence_Positive,
            input_data.Learning_Disabilities_Yes,
            input_data.Parental_Education_Level_High_School,
            input_data.Parental_Education_Level_Postgraduate,
            input_data.Distance_from_Home_Moderate,
            input_data.Distance_from_Home_Near,
            input_data.Gender_Male
        ]])

        prediction = model.predict(input_features)

        return {"prediction": prediction.tolist()}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error making prediction: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)