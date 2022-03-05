from flask import Flask
# Call the application factory function to construct a Flask application
# instance using the development configuration
app = Flask(__name__)

# Create an instance of Freezer for generating the static files from
# the Flask application routes ('/', '/breakfast', etc.)

if __name__ == '__main__':
    # Run the development server that generates the static files
    # using Frozen-Flask
    app.run(debug=True)
