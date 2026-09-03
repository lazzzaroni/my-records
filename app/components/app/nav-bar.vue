<script setup lang="ts">
</script>

<template>
  <header class="flex items-center justify-between border-b px-6 py-4">
    <Button as-child variant="link" class="text-lg font-semibold">
      <NuxtLink to="/">
        Gym Records
      </NuxtLink>
    </Button>
    <div class="flex items-center gap-2">
      <AppThemeToggle />
      <Button>Sign In</Button>
    </div>
  </header>
</template>
