<?php
namespace Tests\Feature;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;
class AuthenticationTest extends TestCase {
    use RefreshDatabase;

    public function test_customer_can_register_and_receive_a_token(): void {
        $response=$this->postJson('/api/v1/register',[
            'name'=>'Mai Nguyen','email'=>'mai@example.com','phone'=>'0901234567',
            'password'=>'secret-pass-123','password_confirmation'=>'secret-pass-123',
        ]);
        $response->assertCreated()->assertJsonPath('user.email','mai@example.com')->assertJsonStructure(['token','user'=>['id','name','email','role']]);
        $this->assertDatabaseHas('users',['email'=>'mai@example.com','role'=>'customer']);
        $this->assertNotEmpty($response->json('token'));
    }

    public function test_registration_validates_duplicate_accounts_and_password_confirmation(): void {
        User::create(['name'=>'Mai Nguyen','email'=>'mai@example.com','password'=>'secret-pass-123']);
        $this->postJson('/api/v1/register',[
            'name'=>'Another Mai','email'=>'mai@example.com',
            'password'=>'secret-pass-123','password_confirmation'=>'different-pass',
        ])->assertUnprocessable()->assertJsonValidationErrors(['email','password']);
    }

    public function test_login_returns_a_token_and_rejects_invalid_credentials(): void {
        User::create(['name'=>'Mai Nguyen','email'=>'mai@example.com','password'=>'secret-pass-123']);
        $this->postJson('/api/v1/login',['email'=>'mai@example.com','password'=>'secret-pass-123'])
            ->assertOk()->assertJsonPath('user.email','mai@example.com')->assertJsonStructure(['token']);
        $this->postJson('/api/v1/login',['email'=>'mai@example.com','password'=>'wrong-password'])
            ->assertUnprocessable()->assertJsonPath('message','Invalid credentials.');
    }

    public function test_bearer_token_protects_profile_and_logout_revokes_current_token(): void {
        $user=User::create(['name'=>'Mai Nguyen','email'=>'mai@example.com','password'=>'secret-pass-123']);
        $token=$user->createToken('test')->plainTextToken;
        $this->withToken($token)->getJson('/api/v1/me')->assertOk()->assertJsonPath('email','mai@example.com');
        $this->withToken($token)->postJson('/api/v1/logout')->assertOk();
        $this->assertNull(PersonalAccessToken::findToken($token));
    }
}
