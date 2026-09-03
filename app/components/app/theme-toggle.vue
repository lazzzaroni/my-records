<script setup lang="ts">
import { MoonIcon, SunIcon } from "@lucide/vue";

const isDark = useDark();
const toggleDark = useToggle(isDark);
</script>

<template>
  <Button
    variant="ghost"
    size="icon"
    :aria-label="isDark ? 'Switch to light theme' : 'Switch to dark theme'"
    @click="toggleDark()"
  >
    <SunIcon v-if="isDark" />
    <MoonIcon v-else />
  </Button>
</template>
