<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiSuggestionController extends Controller
{
    /**
     * @group Admin - Activities
     * @authenticated
     * @bodyParam title string required
     * @bodyParam description string optional
     * @bodyParam safeMax int required
     * @bodyParam criteriaLines string required
     * @bodyParam max_tokens int optional
     * @response { "success": true, "output": "[1, 2]", "raw": {} }
     */
    public function suggest(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'safeMax' => 'required|integer',
            'criteriaLines' => 'required|string',
            'max_tokens' => 'nullable|integer'
        ]);

        $prompt = "You are an AI pedagogical assistant. Propose a maximum of {$request->safeMax} criteria from the following list:\n\n{$request->criteriaLines}\n\nFor the activity titled: \"{$request->title}\" with description: \"{$request->description}\". Returns only a JSON array of the recommended integer criteria IDs without markdown wrappers.";
        $copilotUrl = rtrim((string) config('services.copilot.url', 'http://localhost:4141'), '/') . '/v1/chat/completions';

        try {
            $response = Http::timeout(60)
                ->acceptJson()
                ->post($copilotUrl, [
                    'model' => 'gpt-4o-mini',
                    'messages' => [
                        [
                            'role' => 'user',
                            'content' => $prompt,
                        ],
                    ],
                ]);

            if ($response->successful()) {
                $raw = $response->json();
                $output = trim((string) data_get($raw, 'choices.0.message.content', ''));
                return response()->json([
                    'success' => true,
                    'output' => $output,
                    'raw' => $raw
                ]);
            }

            return response()->json([
                'success' => false,
                'output' => '[]',
                'message' => 'AI server error.'
            ], 500);

        } catch (\Exception $e) {
            Log::error('AI suggestion proxy request failed', [
                'url' => $copilotUrl,
                'message' => $e->getMessage(),
                'exception' => get_class($e),
            ]);

            return response()->json([
                'success' => false,
                'output' => '[]',
                'message' => 'Could not connect to AI proxy: ' . $e->getMessage(),
            ], 500);
        }
    }
}
