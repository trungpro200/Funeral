<?php
use Illuminate\Support\Facades\Artisan;
Artisan::command('about-app', function () { $this->comment('Funeral booking API'); });
