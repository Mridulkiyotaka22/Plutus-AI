from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    """
    Standardize all API error responses:
    {
        "success": false,
        "error": {
            "code": "VALIDATION_ERROR" | "AUTHENTICATION_FAILED" | "NOT_FOUND" | "SERVER_ERROR",
            "message": "...",
            "details": {...}
        }
    }
    """
    response = exception_handler(exc, context)

    if response is not None:
        code = 'API_ERROR'
        if response.status_code == status.HTTP_401_UNAUTHORIZED:
            code = 'AUTHENTICATION_REQUIRED'
        elif response.status_code == status.HTTP_403_FORBIDDEN:
            code = 'PERMISSION_DENIED'
        elif response.status_code == status.HTTP_404_NOT_FOUND:
            code = 'NOT_FOUND'
        elif response.status_code == status.HTTP_400_BAD_REQUEST:
            code = 'VALIDATION_ERROR'

        message = 'An error occurred while processing the request.'
        if isinstance(response.data, dict) and 'detail' in response.data:
            message = str(response.data['detail'])
        elif isinstance(response.data, list) and len(response.data) > 0:
            message = str(response.data[0])

        response.data = {
            'success': False,
            'error': {
                'code': code,
                'status_code': response.status_code,
                'message': message,
                'details': response.data,
            }
        }
    return response
