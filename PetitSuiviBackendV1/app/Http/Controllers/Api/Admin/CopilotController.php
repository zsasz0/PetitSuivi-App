<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CopilotController extends Controller
{
    public function prompt(Request $request): JsonResponse
    {
        // TODO: Delegate handling natural language queries via Azure OpenAI
        return response()->json([
            'success' => true,
            'message' => 'Copilot response generated.',
            'data' => null
        ]);
    }
}
