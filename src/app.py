import datetime
from flask import Flask, request, jsonify, current_app, render_template

app = Flask(__name__)

def square(num):
    return num * num

@app.route('/square', methods=['GET'])
def square_number():
    try:
        # Get the number from query parameter
        number = request.args.get('number', type=float)

        # Check if number was provided
        if number is None:
            return jsonify({"error": "Please provide a number query parameter"}), 400

        # Calculate the square
        result = square(number)

        # Return the result as JSON
        return jsonify({"original-changed": number, "squared": result})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/health')
def health():
    # Basic health check endpoint - always returns healthy
    current_app.logger.debug(f"Health check from {request.remote_addr}")

    return jsonify({
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat()
    })


@app.route('/', methods=['GET', 'POST'])
def calculate_area():
    area = None
    width_value = ''
    height_value = ''
    if request.method == 'POST':
        try:
            width_value = request.form['width']
            height_value = request.form['height']
            width = float(width_value)
            height = float(height_value)
            area = width * height
        except ValueError:
            return render_template('index.html', error='Invalid input. Please enter numeric values.', width=width_value, height=height_value)
    return render_template('index.html', area=area, width=width_value, height=height_value)


if __name__ == '__main__':
    app.run(debug=True)