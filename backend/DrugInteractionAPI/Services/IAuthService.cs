using DrugInteractionAPI.Controllers;

namespace DrugInteractionAPI.Services;

public interface IAuthService
{
    Task<AuthResponse?> AuthenticateGoogleUserAsync(string idToken);
    Task<AuthResponse?> RefreshTokenAsync(string refreshToken);
}