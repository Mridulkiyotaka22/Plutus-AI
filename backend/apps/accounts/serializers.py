from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'base_currency', 'locale', 'tax_jurisdiction',
            'theme_preference', 'email_alerts', 'in_app_alerts', 'bio',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile']

class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'first_name', 'last_name']

    def validate_email(self, value):
        normalized = value.strip().lower()
        if User.objects.filter(email__iexact=normalized).exists():
            raise serializers.ValidationError('An account with this email already exists.')
        return normalized

    def validate_username(self, value):
        normalized = value.strip()
        if not normalized:
            raise serializers.ValidationError('Username is required.')
        if User.objects.filter(username__iexact=normalized).exists():
            raise serializers.ValidationError('This username is already taken.')
        return normalized

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Passwords do not match."})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2', None)
        password = validated_data.pop('password')
        return User.objects.create_user(password=password, **validated_data)

class PlutusTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        # Allow users to sign in with either their username or email address.
        identifier = attrs.get(self.username_field, '')
        if isinstance(identifier, str) and '@' in identifier:
            try:
                matched_user = User.objects.get(email__iexact=identifier.strip())
            except User.DoesNotExist:
                matched_user = None
            if matched_user is not None:
                attrs[self.username_field] = matched_user.get_username()
        data = super().validate(attrs)
        data['user'] = UserSerializer(self.user).data
        return data
