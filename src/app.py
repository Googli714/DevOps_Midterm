from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/square', methods=['GET'])
def square_number():
    try:
        # Get the number from query parameter
        number = request.args.get('number', type=float)

        # Check if number was provided
        if number is None:
            return jsonify({"error": "Please provide a number query parameter"}), 400

        # Calculate the square
        result = number ** 2

        # Return the result as JSON
        return jsonify({"original": number, "squared": result})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)